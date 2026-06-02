import nodemailer, { Transporter } from "nodemailer";
import { ISMTPOptionsObject } from "../../../domain/repositories/ISMTPOptionsObject";
import { SMTPManager } from "../../../domain/repositories/SMTPManager";
import { SentMessageInfo } from "nodemailer/lib/smtp-transport";
import { resetPassMailTemplate } from "../../../../../config/resetPassMailTemplate";
import { SMTPConfig } from "../../../../../config/SMTPConfig";
import { DownloadFormMailTemplate } from "../../../../../config/downloadFormMailTemplate";
import { readFile } from "fs/promises"

export class NodeMailerManager implements SMTPManager {
  private errorVerify: boolean = false;
  private errorMessage: string = "";
  private mailTemplate: string = "";
  private readonly smtpConf: SMTPConfig = new SMTPConfig()
  private readonly smtpOptions: ISMTPOptionsObject = {
    host: this.smtpConf.Options.host!,
    port: Number(this.smtpConf.Options.port),
    secure: this.smtpConf.Options.secure,
    auth:{
      user: this.smtpConf.Options.auth.user!,
      pass: this.smtpConf.Options.auth.pass!
    }
  }

  createTransporter = async (
    smtpOptions: ISMTPOptionsObject = this.smtpOptions
  ): Promise<Transporter<SentMessageInfo>> => {
    const transporter = nodemailer.createTransport(smtpOptions);
    if (await transporter.verify()) {
      return transporter;
    } else {
      this.errorVerify = true;
      this.errorMessage =
        "Hubo un error al generar el SMTP Transporter, el email no será enviado";
      return transporter;
    }
  };

  setResetPassMailTemplate = (name: string, token: string): void => {
    const templateObject: resetPassMailTemplate = new resetPassMailTemplate();
    this.mailTemplate = templateObject.getTemplate(name, token);
  };

  setDownloadFormMailTemplate = (trade_name: string, mounth: string): void => {
    const template: DownloadFormMailTemplate = new DownloadFormMailTemplate();
    this.mailTemplate = template.getTemplate(trade_name, mounth);
  }

  sendEmail = async (
    transporter: Transporter,
    email: string,
    name: string,
    subject: string,
    sender: string = "rbr1594@gmail.com"//"info@dircetur.org"
  ): Promise<boolean> => {
    const emailSend = transporter.sendMail({
      from: `DICETUR <${sender}>`,
      to: `${name} <${email}>`,
      subject: subject,
      html: this.mailTemplate,
    }, (error, info) => {
      if (error) {
        this.errorVerify = true; this.errorMessage = error?.message!
      } else {
        this.errorVerify = false; this.errorMessage = ''
      }
    });
    return (this.errorVerify) ? false : true;
  };

  sendMailWithDocument = async (transporter: any,
    email: string,
    trade_name: string,
    subject: string,
    pdfFilePath: string,
    month: string,
    sender: string = "rbr1594@gmail.com"//"info@dircetur.org"
  ): Promise<boolean> => {
    const pdfFileBase64 = await readFile(pdfFilePath, {encoding: 'base64'});
    const emailSend = await transporter.sendMail({
      from: `DICETUR <${sender}>`,
      to: `${trade_name} <${email}>`,
      subject: subject,
      html: this.mailTemplate,
      attachments: [
        {
          filename: `${trade_name}_formulario_${month}.pdf`,
          content: pdfFileBase64,
          encoding: 'base64' 
        }
      ]
    }, (error: Error, info:any) => {
      if (error) {
        this.errorVerify = true; this.errorMessage = 
          "Hubo un error al enviar el correo con el formulario, pero aun podrá descargarlo en la web de https://www.dircetur.org/documents"
      } else {
        this.errorVerify = false; this.errorMessage = ''
      }
    });
    return (this.errorVerify) ? false : true;
  }

  getErrors = (): string => this.errorMessage;

  error = (): boolean => this.errorVerify;
}
