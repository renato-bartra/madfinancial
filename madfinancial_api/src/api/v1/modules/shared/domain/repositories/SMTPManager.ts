export interface SMTPManager {
  createTransporter: () => Promise<any>;
  setResetPassMailTemplate: (name: string, token: string) => void;
  setDownloadFormMailTemplate: (trade_name: string, mounth: string) => void;
  sendEmail: (
    transporter: any,
    email: string,
    name: string,
    subject: string
  ) => Promise<boolean>;
  sendMailWithDocument: (
    transporter: any,
    email: string,
    trade_name: string,
    subject: string,
    pdfFilePath: string,
    month: string
  ) => Promise<boolean>;
  error: () => boolean;
  getErrors: () => string;
}
