import { Request, Response, Router } from "express";
import { IResponseObject } from "../../../../shared/domain/repositories/IResponseObject";
import { UserController } from "../../../application/controllers";

export class UsersPublicRoutes {
  private readonly router: Router = Router();
  constructor() {
    this.initRoutes();
  }

  private initRoutes = (): void => {
    const userController: UserController = new UserController();
    // Crear nuevo usuario
    this.router.post("/", async function (req:Request, res:Response) {
      const responseObject: IResponseObject = await userController.create(req.body);
      return res.status(responseObject.code).json(responseObject);
    });
    // login de usuario
    this.router.post("/login", async function (req: Request, res: Response) {
      const responseObject: IResponseObject = await userController.login(
        req.body.email,
        req.body.password
      );
      return res.status(responseObject.code).json(responseObject);
    });
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
