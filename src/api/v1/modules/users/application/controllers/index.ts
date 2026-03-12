import { DataValidationException } from "../../../shared/domain/exeptions/DataValidationException";
import { EntityNotFoundException } from "../../../shared/domain/exeptions/EntityNotFoundException";
import { TokenException } from "../../../shared/domain/exeptions/TokenException";
import { IResponseObject } from "../../../shared/domain/repositories/IResponseObject";
import { PasswordManager } from "../../../shared/domain/repositories/PasswordManager";
import { ValidatorManager } from "../../../shared/domain/repositories/ValidatorManager";
import { JWTManager } from "../../../shared/infraestructure/implementations/JWT/JWTManager";
import { PasswordBcrypt } from "../../../shared/infraestructure/implementations/PasswordBcript";
import { EmailValidator } from "../../../shared/infraestructure/implementations/Zod/EmailValidator";
import { User } from "../../domain/entities/User";
import { UserAlreadyExistException } from "../../domain/exceptions/UserAlreadyExistException";
import { PostgreSQLUserRepository } from "../../infraestructure/implementations/PostrgreSQL/PostgreSQLUserRepository";
import { ZodValidator } from "../../infraestructure/implementations/Zod/ZodValidator";
import { GetAllUseCase } from "../usecases/GetAllUseCase";
import { GetByEmailUseCase } from "../usecases/GetByEmailUseCase";
import { GetByIdUseCase } from "../usecases/GetByIdUseCase";
import { UserCreatorUseCase } from "../usecases/UserCreatorUseCase";
import { UserDeleterUseCase } from "../usecases/UserDeleterUseCase";
import { UserLoginUseCase } from "../usecases/UserLoginUseCase";
import { UserUpdaterUseCase } from "../usecases/UserUpdaterUseCase";

export class UserController {
  private data: IResponseObject = { code: 0, message: "", body: [] };
  // private userRepository: MySQLUserRepository = new MySQLUserRepository();
  private userRepository: PostgreSQLUserRepository = new PostgreSQLUserRepository()
  private tokenManager: JWTManager = new JWTManager();
  private passwordManager: PasswordManager = new PasswordBcrypt(11);
  private validatorManager: ValidatorManager = new ZodValidator();
  /* -------------------------------------------------------------------------- */
  /*                         Consigue todos los usuarios                        */
  /* -------------------------------------------------------------------------- */
  getAll = async (): Promise<IResponseObject> => {
    const getAllUseCase = new GetAllUseCase(this.userRepository);
    try {
      const response: User[] = await getAllUseCase.get();
      let users: object[] = [];
      Object.entries(response).forEach(([key, value], i) => {
        let user: object = {
          id: value.user_id,
          first_name: value.first_name,
          last_name: value.last_name,
          dni: value.dni,
          email: value.email,
          image: value.image,
        };
        users[i] = user;
      });
      this.data = {
        code: 200,
        message: "un gran poder conlleva una gran responsabilidad",
        body: users,
      };
    } catch (error) {
      this.data = {
        code: 500,
        message: `Server error: ${error}`,
        body: [],
      };
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                               Crea un usuario                              */
  /* -------------------------------------------------------------------------- */
  create = async (user: User): Promise<IResponseObject> => {
    const userCreatorUseCase = new UserCreatorUseCase(
      this.userRepository,
      this.passwordManager,
      this.validatorManager
    );
    try {
      const userCreate: User = await userCreatorUseCase.create(user);
      // Elimina el password para no mostrarlo en la interface
      this.data = {
        code: 200,
        message: "El Usuario se creó correctamente",
        body: {
          id: userCreate.user_id,
          first_name: userCreate.first_name,
          last_name: userCreate.last_name,
          dni: userCreate.dni,
          email: userCreate.email,
          image: userCreate.image,
        },
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof UserAlreadyExistException) {
        this.data = { code: 400, message: error.message, body: [] };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                        Consugue un usuario por email                       */
  /* -------------------------------------------------------------------------- */
  getByEmail = async (email: string): Promise<IResponseObject> => {
    const getByEmailUseCase = new GetByEmailUseCase(
      this.userRepository,
      new EmailValidator()
    );
    try {
      const user: User = await getByEmailUseCase.get(email);
      this.data = {
        code: 200,
        message: "",
        body: {
          id: user.user_id,
          first_name: user.first_name,
          last_name: user.last_name,
          dni: user.dni,
          email: user.email,
          image: user.image,
        },
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                         Consigue un usuario por ID                         */
  /* -------------------------------------------------------------------------- */
  getById = async (id: number): Promise<IResponseObject> => {
    const getUserByIdUseCase = new GetByIdUseCase(this.userRepository);
    try {
      const user: User = await getUserByIdUseCase.get(id);
      this.data = {
        code: 200,
        message: "",
        body: {
          id: user.user_id,
          first_name: user.first_name,
          last_name: user.last_name,
          dni: user.dni,
          email: user.email,
          image: user.image,
        },
      };
    } catch (error) {
      if (error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                            Actualiza un usuario                            */
  /* -------------------------------------------------------------------------- */
  update = async (id: number, user: User): Promise<IResponseObject> => {
    const userUpdaterUseCase = new UserUpdaterUseCase(
      this.userRepository,
      this.validatorManager
    );
    try {
      const userUpdated: User = await userUpdaterUseCase.update(id, user);
      this.data = {
        code: 200,
        message: "El usuario se actualizó correctamente",
        body: {
          id: userUpdated.user_id,
          first_name: userUpdated.first_name,
          last_name: userUpdated.last_name,
          dni: userUpdated.dni,
          email: userUpdated.email,
          image: userUpdated.image,
        },
      };
    } catch (error) {
      if (error instanceof DataValidationException) {
        this.data = {
          code: 400,
          message: error.message,
          body: error.getErrors(),
        };
      } else if (error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                             Elimina un usuario                             */
  /* -------------------------------------------------------------------------- */
  delete = async (id: number): Promise<IResponseObject> => {
    const userDelterUseCase = new UserDeleterUseCase(this.userRepository);
    try {
      await userDelterUseCase.delete(id);
      this.data = {
        code: 200,
        message: "El usuario se eliminó correctamente",
        body: { success: true },
      };
    } catch (error) {
      if (error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: error.message,
          body: { success: false },
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
  /* -------------------------------------------------------------------------- */
  /*                              Login de usuario                              */
  /* -------------------------------------------------------------------------- */
  login = async (email: string, password: string): Promise<IResponseObject> => {
    const userLoginUseCase = new UserLoginUseCase(
      this.userRepository,
      this.passwordManager,
      this.tokenManager
    );
    try {
      const [token, user]: [string, User] = await userLoginUseCase.login(email, password);
      this.data = {
        code: 200,
        message: token,
        body: {
          id: user.user_id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.last_name,
          dni: user.dni
        },
      };
    } catch (error) {
      if (error instanceof EntityNotFoundException) {
        this.data = {
          code: 404,
          message: "El usuario o la contraseña son incorrectos",
          body: [],
        };
      } else if (error instanceof TokenException) {
        this.data = {
          code: 400,
          message: error.message,
          body: [],
        };
      } else {
        this.data = {
          code: 500,
          message: `Server error: ${error}`,
          body: [],
        };
      }
    }
    return this.data;
  };
}
