import dotenv from 'dotenv-flow';

dotenv.config();

export class DBConfig {
    public readonly postgreSQLConn = {
        host: process.env.PDB_HOST,
        port: process.env.PDB_PORT ? parseInt(process.env.PDB_PORT) : 5432,
        user: process.env.PDB_USER,
        password: process.env.PDB_PASSWORD,
        database: process.env.PDB_DATABASE,
    }
}