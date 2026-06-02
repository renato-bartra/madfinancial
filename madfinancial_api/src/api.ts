import express, { Application } from "express";
import dotenv from "dotenv-flow";
import helmet from "helmet";
import requestIp from "request-ip";
import Killport from "kill-port";
import morgan from "morgan";
import cors from "cors"
import Routes from "./routes/index.routes";

export class Api {
  // Init atributes
  private app: Application;
  private whitelist = [
    `http://localhost:${process.env.PORT}`, 
    'http://localhost:4200',
  ];
  private readonly options: cors.CorsOptions = {
    origin: this.whitelist
  };

  constructor(private port?: number) {
    this.app = express();
    this.middlewares();
    this.settings();
    this.routes()
  }

  // Init api settings
  private settings = (): void => {
    dotenv.config();
    this.app.set("port", process.env.PORT || this.port);
    this.app.set("helmet", { frameguard: { action: "sameorigin" } });
    this.app.set("formidable", { multiples: true });
  };

  // Midlewares
  private middlewares = (): void => {
    this.app.use(morgan("dev"));
    this.app.use(helmet(this.app.get("helmet")));
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
    this.app.use(requestIp.mw());
  }

  // Routes
  private routes = (): void => {
    new Routes(this.app)
  }

  // Start http server
  listen = async (): Promise<string> => {
    const port: number = parseInt(this.app.get("port"));
    try {
      await Killport(port);
      this.app.use(cors(this.options));
      this.app.listen(port);
      return `Server listen on port: ${port}`;
    } catch (error) {
      return `Error when trying to start server on port ${port}`;
    }
  };
}
