import { Request, Response, Router } from "express";
import { SharedController } from "../../../application/controllers/SharedController";
import { IResponseObject } from "../../../domain/repositories/IResponseObject";
import { VerifyTokenController } from "../../../application/controllers/VerifyTokenController";

export class SharedPublicRoutes {
  private readonly router: Router = Router();
  constructor() {
    this.initRoutes();
  }

  private initRoutes = (): void => {
    const sharedController: SharedController = new SharedController();
    const verifyTokenController: VerifyTokenController = new VerifyTokenController();
    // Reset password Route
    this.router.put(
      "/reset-password",
      async function (req: Request, res: Response) {
        const responseObject:IResponseObject = await sharedController.resetPassword(
          req.body.token,
          req.body.password,
          req.body.confirm
        )
        return res.status(responseObject.code).json(responseObject);
      }
    );
    // Forgot passsword Route
    this.router.post(
      '/forgot-password',
      async function (req: Request, res: Response) {
        const responseObject: IResponseObject = await sharedController.forgotPass(
          req.body.email
        )
        return res.status(responseObject.code).json(responseObject);
      }
    );
    // Verify token route
    this.router.post(
      '/verify-token',
      async function(req:Request, res: Response) {
        const responseObject: IResponseObject|boolean = await verifyTokenController.verify(
          req.body.token,
          [req.body.role]
        )
        if(typeof responseObject == 'boolean')
          return res.status(200).json(true);
        else
          return res.status(responseObject.code).json(responseObject);
      }
    )
  }

  getRoutes = (): Router => this.router;
}