import { Router, Request, Response } from 'express';
import { container, ServiceTokens } from '../di/container';
import logger from '../utils/logger';
import Content from '../models/Content';
import { authenticateToken, AuthenticatedRequest } from '../middleware/auth';
import { validate, ContentValidation, BaseSchemas } from '../validation';
import Joi from 'joi';

// Get services from DI container  
const getBiasRatingService = () => container.get(ServiceTokens.BiasRatingService);

const router = Router();

// Public routes (no auth required)
router.get('/trending', 
  validate({ query: ContentValidation.trendingTopics }),
  async (req: Request, res: Response) => {
    try {
      const { days = 7, limit = 10 } = req.query;
      
      const topics = await Content.getTrendingTopics(Number(days));
      
      res.json(topics.slice(0, Number(limit)));
    } catch (error) {
      logger.error('Error fetching trending topics:', error);
      res.status(500).json({ error: 'Failed to fetch trending topics' });
    }
  }
);

router.get('/articles/:id', 
  validate({ params: Joi.object({ id: BaseSchemas.id }) }),
  async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      
      const article = await Content.findArticleById(Number(id));
      
      if (!article) {
        return res.status(404).json({ error: 'Article not found' });
      }
      
      res.json(article);
    } catch (error) {
      logger.error('Error fetching article:', error);
      res.status(500).json({ error: 'Failed to fetch article' });
    }
  }
);

router.get('/search',
  validate({ query: ContentValidation.searchContent }),
  async (req: Request, res: Response) => {
    try {
      const { q, bias, dateFrom, dateTo, sources } = req.query;
      
      const filters: any = {};
      
      if (bias) {
        filters.bias = Array.isArray(bias) ? bias : [bias];
      }
      
      if (dateFrom) {
        filters.dateFrom = new Date(dateFrom as string);
      }
      
      if (dateTo) {
        filters.dateTo = new Date(dateTo as string);
      }
      
      if (sources) {
        filters.sources = Array.isArray(sources) 
          ? sources.map(s => Number(s))
          : [Number(sources)];
      }
      
      const articles = await Content.searchArticles(q as string, filters);
      
      res.json(articles);
    } catch (error) {
      logger.error('Error searching articles:', error);
      res.status(500).json({ error: 'Failed to search articles' });
    }
  }
);

router.get('/topic/:topic', 
  validate({ 
    params: Joi.object({ topic: BaseSchemas.mediumString }),
    query: ContentValidation.topicArticles
  }),
  async (req: Request, res: Response) => {
    try {
      const { topic } = req.params;
      const { count = 3 } = req.query;
      
      const articles = await Content.getBalancedArticles(topic, Number(count));
      
      res.json({
        topic,
        articles,
        biasDistribution: getBiasRatingService().getBiasDistribution(articles),
      });
    } catch (error) {
      logger.error('Error fetching articles by topic:', error);
      res.status(500).json({ error: 'Failed to fetch articles' });
    }
  }
);

// Authenticated routes
router.use(authenticateToken);

router.get('/feed',
  validate({ query: ContentValidation.feedQuery }),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.id;
      const { date } = req.query;
      
      const feedDate = date ? new Date(date as string) : new Date();
      const feed = await Content.getDailyFeed(userId, feedDate);
      
      res.json(feed);
    } catch (error) {
      logger.error('Error fetching feed:', error);
      res.status(500).json({ error: 'Failed to fetch feed' });
    }
  }
);

router.get('/recommendations',
  validate({ query: ContentValidation.recommendations }),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.id;
      const { topic, count = 6 } = req.query;
      
      const recommendations = await getBiasRatingService().getBalancedRecommendations(
        userId,
        topic as string,
        Number(count)
      );
      
      res.json(recommendations);
    } catch (error) {
      logger.error('Error fetching recommendations:', error);
      res.status(500).json({ error: 'Failed to fetch recommendations' });
    }
  }
);

router.post('/articles/:id/view',
  validate({ params: Joi.object({ id: BaseSchemas.id }) }),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
      
      await Content.logContentView(userId, Number(id));
      
      res.json({ message: 'View logged successfully' });
    } catch (error) {
      logger.error('Error logging view:', error);
      res.status(500).json({ error: 'Failed to log view' });
    }
  }
);

router.get('/history',
  validate({ query: ContentValidation.contentHistory }),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.id;
      const { days = 30 } = req.query;
      
      const history = await Content.getUserContentHistory(userId, Number(days));
      
      res.json(history);
    } catch (error) {
      logger.error('Error fetching history:', error);
      res.status(500).json({ error: 'Failed to fetch history' });
    }
  }
);

router.get('/bias-analysis',
  validate({ query: ContentValidation.biasAnalysis }),
  async (req: AuthenticatedRequest, res: Response) => {
    try {
      const userId = req.user!.id;
      const { days = 30 } = req.query;
      
      const analysis = await getBiasRatingService().analyzeUserBias(userId, Number(days));
      
      res.json(analysis);
    } catch (error) {
      logger.error('Error analyzing bias:', error);
      res.status(500).json({ error: 'Failed to analyze bias' });
    }
  }
);

export default router; 
