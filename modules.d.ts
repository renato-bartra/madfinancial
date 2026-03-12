declare module "kill-port";
declare module NodeJS {
  interface Global {
    io: any;
    connection: any;
  }
}