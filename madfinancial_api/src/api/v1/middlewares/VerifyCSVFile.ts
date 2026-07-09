import multer from "multer";
import { Request, Response, NextFunction } from "express";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
});

export const VerifyCSVFileMiddleware = () => {
  const middleware = upload.single("file");
  return (req: Request, res: Response, next: NextFunction) => {
    middleware(req, res, (err) => {
      if (err) {
        return res.status(404).json({
          code: 404,
          message: err.message,
          body: [],
        });
      }

      if (!req.file) {
        return res.status(404).json({
          code: 404,
          message: "Debe enviar un archivo CSV.",
          body: [],
        });
      }
      
      next();
    });
  };
};