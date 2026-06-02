import { Application, Router } from "express";
import { PublicRoutes } from "./v1/public.routes";
import { PrivateRoutes } from "./v1/private.routes";

class Routes {
  private app: Application;
  private publicRoutes: PublicRoutes = new PublicRoutes();
  private privateRoutes: PrivateRoutes = new PrivateRoutes();

  // Para iniciar todas las rutas del API 
  constructor(application: Application) {
    this.app = application;
    this.publicRouter();
  }

  // Init public routes, with no login
  public publicRouter = () => {
    const publicRouter: Router = this.publicRoutes.getRoutes();
    const privateRoutes: Router = this.privateRoutes.getRoutes();
    this.app.use("/api/v1", publicRouter);
    this.app.use('/api/v1', privateRoutes);
    this.app.use(function(req, res) {
      let ip = req.clientIp;
      res.end(`from: ${ip}`+'\n')
    })
  };
}

export default Routes;
