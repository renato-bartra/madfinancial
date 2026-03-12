import { Router } from "express";
import { UserPrivateRoutes } from "../../api/v1/modules/users/infraestructure/implementations/routes/private.routes";

export class PrivateRoutes {
  private readonly router: Router = Router();
  private readonly userRouter: UserPrivateRoutes = new UserPrivateRoutes();

  constructor() {
    this.initRoutes();
  }

  private initRoutes = () => {
    this.router.use("/users", this.userRouter.getRoutes());
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
