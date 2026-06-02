import { ConnectionOptions, ResultSetHeader, RowDataPacket } from "mysql2";
import { MySQLAdapter } from "./MySQLAdapter";

export class MySQLExecuteAdapter {
  protected errorWatcher: boolean = false;
  protected ErrorMessage: string = "";

  constructor(
    private readonly mysqlAdapter: MySQLAdapter = new MySQLAdapter(),
    private readonly connOptions: ConnectionOptions
  ) {
    this.errorWatcher = false;
    this.ErrorMessage = "";
  }

  /* -------------------------------------------------------------------------- */
  /*              Ejecuta una query y devuelve rows y el header                 */
  /* -------------------------------------------------------------------------- */
  exececuteQuery = async (queryString: string, queryParams: any[]): Promise<[RowDataPacket[], ResultSetHeader] | null> => {
    const promiseConn = await this.mysqlAdapter.createConection(this.connOptions);
    try {
      // Crea la conexión
      const [rows] = await promiseConn
        .promise()
        .execute<[RowDataPacket[], ResultSetHeader]>(queryString, queryParams);
      // Seta la respuesta a un array de tipo [RowDataPacket[], ResultSetHeader] por que eso es lo que devuelve un SP de mysql
      let response = rows as [RowDataPacket[], ResultSetHeader];
      // Si no devuelve nada entonces null
      if (rows[0].length === 0) return null;
      if (!Array.isArray(rows[0])) return null
      // Retorna respuesta
      return response;
    } catch (error) {
      this.errorWatcher = true
      this.ErrorMessage = String(error);
    } finally {
      promiseConn.end();
    }
    return null
  };

  /* -------------------------------------------------------------------------- */
  /*                Ejecuta una query y solo devuelve el header                 */
  /* -------------------------------------------------------------------------- */
  exececuteQueryWitoutRows = async (queryString: string, queryParams: any[]): Promise<ResultSetHeader | null> => {
    const promiseConn = await this.mysqlAdapter.createConection(this.connOptions);
    try {
      // Crea la conexión
      const [rows] = await promiseConn
        .promise()
        .execute<ResultSetHeader>(queryString, queryParams);
      // Seta la respuesta a un array de tipo ResultSetHeader por que eso es lo que devuelve un SP de mysql
      let response = rows as ResultSetHeader;
      // Si no devuelve nada entonces null
      if (!rows) return null;
      if (!rows.affectedRows) return null
      // Retorna respuesta
      return response;
    } catch (error) {
      this.errorWatcher = true
      this.ErrorMessage = String(error);
    } finally {
      promiseConn.end();
    }
    return null
  };

  /* -------------------------------------------------------------------------- */
  /*                Ejecuta una query y solo devuelve el header                 */
  /* -------------------------------------------------------------------------- */
  exececuteQueryWitoutParams = async (queryString: string): Promise<[RowDataPacket[], ResultSetHeader] | null> => {
    const promiseConn = await this.mysqlAdapter.createConection(this.connOptions);
    try {
      // Crea la conexión
      const [rows] = await promiseConn
        .promise()
        .execute<[RowDataPacket[], ResultSetHeader]>(queryString);
      // Seta la respuesta a un array de tipo [RowDataPacket[], ResultSetHeader] por que eso es lo que devuelve un SP de mysql
      let response = rows as [RowDataPacket[], ResultSetHeader];
      // Si no devuelve nada entonces null
      if (rows[0].length === 0) return null;
      if (!Array.isArray(rows[0])) return null
      // Retorna respuesta
      return response;
    } catch (error) {
      this.errorWatcher = true
      this.ErrorMessage = String(error);
    } finally {
      promiseConn.end();
    }
    return null
  };

  hasError = (): boolean => { return this.errorWatcher };
  getError = (): string => { return this.ErrorMessage }
}
