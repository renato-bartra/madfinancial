import { Router, Response, Request  } from "express";
import { AccountController } from "../../application/controllers";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import VerifyTokenMiddleware from "../../../../middlewares/VerifyToken";

export class AccountPrivateRoutes {
  private readonly router: Router = Router()

  constructor () {this.initRoutes()}

  private initRoutes = (): void => {
    const accountController = new AccountController();
    let responseObject: IResponseObject = {code:0, message:'', body:[]}
    // Middlewares: Valida el token de usuario 
    this.router.use(VerifyTokenMiddleware(['user']));
    // Luego ejecuta las rutas
    this.router.route("/")
      // consigue todos las cuentas de un usuario
      .get(async function(req:Request, res:Response) {
          responseObject = await accountController.getAll(Number(req.body.user_id))
          return res.status(responseObject.code).json(responseObject);
        })
      // Crea un nuevo account de un usuario
      .post(async function(req:Request, res:Response) {
          responseObject = await accountController.create(req.body)
          return res.status(responseObject.code).json(responseObject);
        })
  }

  public getRoutes = (): Router => {
    return this.router;
  }
}