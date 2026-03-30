import { Router } from "express";
import { UserPrivateRoutes } from "../../api/v1/modules/users/infraestructure/implementations/routes/private.routes";
import { TagPrivateRoutes } from "../../api/v1/modules/tags/infraestructure/routes/private.routes";
import { CategoryPrivateRoutes } from "../../api/v1/modules/catecories/infraestructure/routes/private.routes";
import { AccountPrivateRoutes } from "../../api/v1/modules/accounts/infraestructure/routes/private.routes";

export class PrivateRoutes {
  private readonly router: Router = Router();
  private readonly userRouter: UserPrivateRoutes = new UserPrivateRoutes();
  private readonly tagRoutes: TagPrivateRoutes = new TagPrivateRoutes();
  private readonly categoryRoutes: CategoryPrivateRoutes = new CategoryPrivateRoutes();
  private readonly accountRoutes: AccountPrivateRoutes = new AccountPrivateRoutes();

  constructor() {
    this.initRoutes();
  }

  private initRoutes = () => {
    this.router.use("/users", this.userRouter.getRoutes());
    this.router.use("/tags", this.tagRoutes.getRoutes());
    this.router.use("/categories", this.categoryRoutes.getRoutes());
    this.router.use("/accounts", this.accountRoutes.getRoutes());
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
