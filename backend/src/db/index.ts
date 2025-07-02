import knex from 'knex';
import knexConfig from '../../knexfile';
import logger from '../utils/logger';

// Use the appropriate configuration based on environment
const environment = process.env.NODE_ENV || 'development';
const dbConfig = knexConfig[environment as keyof typeof knexConfig];

const db = knex(dbConfig);

// Test database connection (deferred to allow app startup)
setTimeout(() => {
  db.raw('SELECT 1')
    .then(() => {
      logger.info(`Database connected successfully (${dbConfig.client})`);
    })
    .catch((err: Error) => {
      logger.error('Database connection failed:', err);
      // Don't exit - just log the error for debugging
    });
}, 2000);

export default db; 