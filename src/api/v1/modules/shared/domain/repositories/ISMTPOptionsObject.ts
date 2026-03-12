export interface ISMTPOptionsObject {
  host: string,
  port: number,
  secure: boolean,
  auth:{
    user: string,
    pass: string
  }
}