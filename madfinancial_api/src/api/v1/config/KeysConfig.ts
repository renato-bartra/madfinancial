import dotenv from 'dotenv-flow';

dotenv.config();

export class KeysConfig {
    // For now there is only one pool
    public readonly keys = {
        jwtSecret: String(process.env.KEY_SECRET),
        jwtMailSecret: String(process.env.KEY_SMTP_SECRET),
    };
}