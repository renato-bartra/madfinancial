import { Request, Response, Router } from "express";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import VerifyTokenMiddleware from "../../../../middlewares/VerifyToken";
import { FileController } from "../../application/controllers";
import { VerifyCSVFileMiddleware } from "../../../../middlewares/VerifyCSVFile";
import { JWTManager } from "../../../shared/infraestructure/implementations/JWT/JWTManager";

export class FilePrivateRoutes {
  private readonly router: Router = Router();
  private readonly jwtManager: JWTManager = new JWTManager();

  constructor(){
    this.initRoutes();
  }

  private initRoutes = (): void => {
    const fileController: FileController = new FileController();
    // Middlewares: Valida el token de usuario 
    this.router.use(VerifyTokenMiddleware(['user']));
    this.router.use(VerifyCSVFileMiddleware());
    // Luego ejecuta las rutas
    this.router.post("/", async (req:Request, res:Response) => {
      const token = String(req.headers.authorization).replace("Bearer ", "");
      const tokenObject = this.jwtManager.verify(token);
      const responseObject = await fileController.import(Number(tokenObject.sub), req.file!.buffer);
      return res.status(responseObject.code).json(responseObject);
    })
  }

  public getRoutes = (): Router => {
    return this.router;
  }
}