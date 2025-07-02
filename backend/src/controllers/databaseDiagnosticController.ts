import { Request, Response } from 'express';
import db from '../db';
import logger from '../utils/logger';

export const checkDatabaseConnection = async (req: Request, res: Response) => {
  try {
    // Test basic connection
    await db.raw('SELECT 1');
    
    // Get database info
    const client = db.client.config.client;
    const connectionInfo = {
      client,
      connected: true,
      environment: process.env.NODE_ENV,
      hasConnectionString: !!process.env.DATABASE_URL,
      ssl: process.env.DB_SSL === 'true'
    };

    // Test users table exists
    let tablesExist = false;
    let userCount = 0;
    try {
      const result = await db('users').count('* as count');
      userCount = parseInt(String(result[0].count));
      tablesExist = true;
    } catch (error) {
      logger.error('Users table check failed:', error);
    }

    res.json({
      database: connectionInfo,
      tables: {
        usersTableExists: tablesExist,
        userCount
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Database diagnostic failed:', error);
    res.status(500).json({
      error: {
        code: 'DB_CONNECTION_FAILED',
        message: 'Database connection test failed',
        details: error instanceof Error ? error.message : 'Unknown error'
      }
    });
  }
};

export const checkMigrationStatus = async (req: Request, res: Response) => {
  try {
    // Check if migrations table exists
    let migrationsExist = false;
    let completedMigrations: string[] = [];
    
    try {
      const migrations = await db('knex_migrations').select('name').orderBy('id', 'desc');
      migrationsExist = true;
      completedMigrations = migrations.map(m => m.name);
    } catch (error) {
      logger.error('Migration table check failed:', error);
    }

    // List all tables
    let tables: string[] = [];
    try {
      if (db.client.config.client === 'postgresql') {
        const result = await db.raw(`
          SELECT tablename FROM pg_tables 
          WHERE schemaname = 'public' 
          ORDER BY tablename
        `);
        tables = result.rows.map((r: any) => r.tablename);
      } else if (db.client.config.client === 'sqlite3') {
        const result = await db.raw(`
          SELECT name FROM sqlite_master 
          WHERE type='table' 
          ORDER BY name
        `);
        tables = result.map((r: any) => r.name);
      }
    } catch (error) {
      logger.error('Table listing failed:', error);
    }

    res.json({
      migrations: {
        tableExists: migrationsExist,
        completed: completedMigrations,
        count: completedMigrations.length
      },
      tables: {
        list: tables,
        count: tables.length
      },
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Migration status check failed:', error);
    res.status(500).json({
      error: {
        code: 'MIGRATION_CHECK_FAILED',
        message: 'Failed to check migration status',
        details: error instanceof Error ? error.message : 'Unknown error'
      }
    });
  }
};