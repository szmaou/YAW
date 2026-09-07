import dotenv from 'dotenv';
dotenv.config();
export const env = {
  port: parseInt(process.env.APP_PORT || '3000', 10),
  nodeEnv: process.env.APP_ENV || 'development',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    name: process.env.DB_NAME || 'yaw',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'dev_secret_change_me',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  uploadPath: process.env.UPLOAD_PATH || './uploads',
  corsOrigin: process.env.CORS_ORIGIN || '*',
};
