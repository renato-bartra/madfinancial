export interface ImportMovement{
    Tipo: string;
    Categoria: string;
    Cuenta: string;
    Titulo: string;
    Monto: number;
    Descripcion: string;
    Fecha: string;
}

export interface DBImportMovement{
    type_id: number;
    category_id: number;
    account_id: number;
    title: string;
    amount: number;
    accounting_date: string
}