import dotenv from 'dotenv-flow';

dotenv.config();

export class SMTPConfig {

  public readonly Options = {
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT),
    secure: true,
    auth:{
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    },
    senderInfo: 'info@dircetur.org',
  }
}