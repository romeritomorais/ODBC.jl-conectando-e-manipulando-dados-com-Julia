using Pkg;

Pkg.add("ODBC");
Pkg.add("DataFrames");

using ODBC;
using DataFrames;

#CRIANDO ARQUIVO COM AS CREDENCIAIS DE ACESSO

open("FileCredentials.txt", "w") do io
           write(io, "SQLSERVER\n")
           write(io, "logon\n")
           write(io, "11111111\n")
           end;

#CARREGANDO ARQUIVO DE LOGIN

login = readlines("FileCredentials.txt")
credenciais = ODBC.DSN(login[1],
                       login[2],
                       login[3]);

#FAZENDO PRIMEIRO 'SELECT'

consulta = ODBC.query(credenciais,
                      "SELECT 
                           FirstName+' '+LastName AS Nome,
                           BirthDate,
                           MaritalStatus,
                           Education,
                           TotalChildren 
                       FROM [dbo].[DimCustomer]"
                     ) |> DataFrame!


first(consulta,10)

#EXECUTANDO UPDATE

ODBC.execute!(credenciais, "UPDATE [dbo].[DimCustomer] 
                            set FirstName ='Julia' 
                            WHERE FirstName = 'RM@@@@@@@@@@@@@'")

select = ODBC.query(credenciais,
                      "SELECT 
                           FirstName+' '+LastName AS Nome,
                           BirthDate,
                           MaritalStatus,
                           Education,
                           TotalChildren 
                       FROM [dbo].[DimCustomer]"
                    ) |> DataFrame!


first(select , 10)

#CLONANDO TABELA A PARTIR DE OUTRA EXISTENTE

ODBC.execute!(credenciais, "select * INTO NovaTabela 
                            FROM [dbo].[DimCustomer]")

select = ODBC.query(credenciais,
                      "SELECT 
                           FirstName+' '+LastName AS Nome,
                           BirthDate,
                           MaritalStatus,
                           Education,
                           TotalChildren 
                       FROM [dbo].[NovaTabela]"
                    ) |> DataFrame!


first(select , 10)

#DELETANDO LINHA ESPECIFICA DA TABELA

ODBC.execute!(credenciais, "DELETE FROM [dbo].[NovaTabela] 
                            WHERE FirstName = 'Julia' ")

select = ODBC.query(credenciais,
                      "SELECT 
                           FirstName+' '+LastName AS Nome,
                           BirthDate,
                           MaritalStatus,
                           Education,
                           TotalChildren 
                       FROM [dbo].[NovaTabela]"
                    ) |> DataFrame!

first(select, 10)

#EXIBINDO TODAS AS TABELAS DO BANCO DE DADOS
select = ODBC.query(credenciais,
                      "SELECT 
                           name AS Tables 
                       FROM SYSOBJECTS WHERE XTYPE='U' ORDER BY name"
                   ) |> DataFrame!

#DELETANDO A TABELA 'NovaTabela' 

ODBC.execute!(credenciais, "DROP TABLE [dbo].[NovaTabela]")

select = ODBC.query(credenciais,
                      "SELECT 
                           name AS Tables 
                       FROM SYSOBJECTS WHERE XTYPE='U' ORDER BY name"
                   ) |> DataFrame!

#FECHANDO A CONEXÃO COM O BANCO DE DADOS
ODBC.disconnect!(credenciais)
