import { Router, Response, Request  } from "express";
import { TagController } from "../../application/controllers";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import VerifyTokenMiddleware from "../../../../middlewares/VerifyToken";

export class TagPrivateRoutes {
  private readonly router: Router = Router()

  constructor () {this.initRoutes()}

  private initRoutes = (): void => {
    const tagController = new TagController();
    let responseObject: IResponseObject = {code:0, message:'', body:[]}
    // Middlewares: Valida el token de usuario 
    this.router.use(VerifyTokenMiddleware(['user']));
    // Luego ejecuta las rutas
    this.router.route("/")
      // consigue todos los tags de un usuario
      .get(async function(req:Request, res:Response) {
          responseObject = await tagController.getAll(Number(req.body.user_id))
          return res.status(responseObject.code).json(responseObject);
        })
      // Crea un nuevo tag de un usuario
      .post(async function(req:Request, res:Response) {
          responseObject = await tagController.create(req.body)
          return res.status(responseObject.code).json(responseObject);
        })
  }

  public getRoutes = (): Router => {
    return this.router;
  }
}