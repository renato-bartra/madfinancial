import mysql, { Connection, ConnectionOptions, Pool, PoolOptions } from 'mysql2'

export class MySQLAdapter {
  /* -------------------------------------------------------------------------- */
  /*                          Crea un pool de conexión                          */
  /* -------------------------------------------------------------------------- */
  createPool = async (poolOptions: PoolOptions): Promise<Pool> => {
    const pool: Pool =  mysql.createPool(poolOptions);
    return pool;
  }
  /* -------------------------------------------------------------------------- */
  /*                          crea una conección simple                         */
  /* -------------------------------------------------------------------------- */
  createConection = async (connOptions: ConnectionOptions): Promise<Connection> => {
    const conn: Connection = mysql.createConnection(connOptions);
    return conn
  } 
}