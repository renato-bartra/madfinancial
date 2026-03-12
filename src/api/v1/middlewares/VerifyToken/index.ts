import { NextFunction, Request, Response } from "express";
import { VerifyTokenController } from "../../modules/shared/application/controllers/VerifyTokenController";
import { IResponseObject } from "../../modules/shared/domain/repositories/IResponseObject";

const VerifyTokenMiddleware = (roles: string[]): ((req: Request, res: Response, next: NextFunction) => void) => {
  const verifyTokenController: VerifyTokenController = new VerifyTokenController();
  return async function (req:Request, res:Response, next:NextFunction) {
    // Primero valida si existe una autorización (token) en la peticion HTTP
    if (!req.headers.authorization) 
      return res.status(403).json({ message: '¡No se enviaron las credenciales!' });
    // Validate token and validate user roles
    const responseObject: IResponseObject|boolean = await verifyTokenController.verify(
      req.headers.authorization,
      roles
    );
    if (typeof responseObject !== 'boolean') 
      return res.status(responseObject.code).json(responseObject);
    // Si todo esta bien next
    next();
  }
}

export default VerifyTokenMiddleware;