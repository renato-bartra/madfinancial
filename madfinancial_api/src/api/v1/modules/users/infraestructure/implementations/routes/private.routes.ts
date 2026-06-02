import { Request, Response, Router } from "express";
import VerifyTokenMiddleware from "../../../../../middlewares/VerifyToken";
import { IResponseObject } from "../../../../../modules/shared/domain/repositories/IResponseObject";
import { UserController } from "../../../application/controllers"

export class UserPrivateRoutes {
  private readonly router: Router = Router();
  constructor(){
    this.initRoutes();
  }

  private initRoutes = (): void => {
    const userController: UserController = new UserController();
    let responseObject: IResponseObject = {code:0, message:'', body:[]}
    // Middlewares: Valida el token de usuario 
    this.router.use(VerifyTokenMiddleware(['user']));
    // Luego ejecuta las rutas
    this.router.get("/", async function(req:Request, res:Response) {
        responseObject = await userController.getAll()
        return res.status(responseObject.code).json(responseObject);
      })
    this.router.route('/:id')
      .put(async function(req:Request, res:Response) {
        const id: number = Number(req.params.id);
        responseObject = await userController.update(id, req.body);
        return res.status(responseObject.code).json(responseObject);
      })
      .get(async function(req:Request, res:Response) {
        const id:number = Number(req.params.id);
        responseObject = await userController.getById(id);
        return res.status(responseObject.code).json(responseObject);
      })
    this.router.route('/get-by-email/:email')
      .get(async function(req:Request, res:Response) {
        const email: string = req.params.email;
        responseObject = await userController.getByEmail(email);
        return res.status(responseObject.code).json(responseObject);
      })

  }

  public getRoutes = (): Router => {
    return this.router;
  }
}