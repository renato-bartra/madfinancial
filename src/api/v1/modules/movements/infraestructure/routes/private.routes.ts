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
      const token = String(req.headers.authorization).replace("Bearer ", "");
      const tokenObject = this.jwtManager.verify(token);
      const responseObject: IResponseObject = await this.movementController.create(
        req.body,
        Number(tokenObject.sub)
      );
      return res.status(responseObject.code).json(responseObject);
    });

    this.router.get("/", async (req: Request, res: Response) => {
      const token = String(req.headers.authorization).replace("Bearer ", "");
      const tokenObject = this.jwtManager.verify(token);
      const responseObject: IResponseObject = await this.movementController.getByMonth(
        Number(tokenObject.sub),
        req.body.accounting_date
      );
      return res.status(responseObject.code).json(responseObject);
    });

    this.router.put("/:movement_id", async (req: Request, res: Response) => {
      const token = String(req.headers.authorization).replace("Bearer ", "");
      const tokenObject = this.jwtManager.verify(token);
      const responseObject: IResponseObject = await this.movementController.update(
        Number(req.params.movement_id),
        req.body,
        Number(tokenObject.sub)
      );
      return res.status(responseObject.code).json(responseObject);
    });

    this.router.delete("/:movement_id", async (req: Request, res: Response) => {
      const responseObject: IResponseObject = await this.movementController.delete(
        Number(req.params.movement_id)
      );
      return res.status(responseObject.code).json(responseObject);
    });
  };

  public getRoutes = (): Router => {
    return this.router;
  };
}
