import { Request, Response, Router } from "express";
import VerifyTokenMiddleware from "../../../../middlewares/VerifyToken";
import { IResponseObject } from "../../../../modules/shared/domain/repositories/IResponseObject";
import { JWTManager } from "../../../../modules/shared/infraestructure/implementations/JWT/JWTManager";
import { MovementController } from "../../application/controllers";

export class MovementPrivateRoutes {
  private readonly router: Router = Router();
  private readonly jwtManager: JWTManager = new JWTManager();
  private readonly movementController: MovementController = new MovementController();

  constructor() {
    this.initRoutes();
  }

  private initRoutes = (): void => {
    this.router.use(VerifyTokenMiddleware(["user"]));

    this.router.post("/", async (req: Request, res: Response) => {
      const tokenObject = this.jwtManager.verify(String(req.headers.authorization));
      const responseObject: IResponseObject = await this.movementController.create(
        req.body,
        Number(tokenObject.sub)
      );
      return res.status(responseObject.code).json(responseObject);
    });

    this.router.get("/", async (req: Request, res: Response) => {
      const tokenObject = this.jwtManager.verify(String(req.headers.authorization));
      const responseObject: IResponseObject = await this.movementController.getByMonth(
        tokenObject.sub,
        req.body.accounting_date
      );
      return res.status(responseObject.code).json(responseObject);
    });
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
