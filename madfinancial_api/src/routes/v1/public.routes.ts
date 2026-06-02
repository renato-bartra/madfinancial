import { Router } from "express";
import { SharedPublicRoutes } from "../../api/v1/modules/shared/infraestructure/implementations/routes/public.routes";
import { UsersPublicRoutes } from "../../api/v1/modules/users/infraestructure/implementations/routes/public.routes";

export class PublicRoutes {
  public readonly publicRouter: Router = Router();
  private readonly usersPublicRoutes: UsersPublicRoutes = new UsersPublicRoutes();
  private readonly sharedController: SharedPublicRoutes = new SharedPublicRoutes();

  //Para iniciar las rutas publicas solo se llama en index.routes.ts
  constructor() {
    this.initRoutes();
  }

  // Crea las rutas publicas, que se devolveran con getRoutes() 
  public initRoutes = (): void => {
    this.publicRouter.use('/', this.sharedController.getRoutes());
    this.publicRouter.use("/users", this.usersPublicRoutes.getRoutes());
  };

  public getRoutes = (): Router => {
    return this.publicRouter;
  };
}
