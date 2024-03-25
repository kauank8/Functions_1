Create database Function_Ex1
go 
Use Function_Ex1
go
Create table Funcionario(
codigo int not null,
nome varchar(150) not null,
salario decimal(7,2) not null
Primary key(codigo)
)
go
Create table Dependente(
codigo_dep int not null,
codigo_func int not null,
nome varchar(150) not null,
salario decimal(7,2) not null
Primary key(codigo_dep)
Foreign key(codigo_func) references Funcionario(codigo)
)
go
Insert into Funcionario Values
(4, 'Ana', 3200.00),
(5, 'Carlos', 2900.00),
(6, 'Mariana', 3100.00),
(7, 'Rafael', 3300.00),
(8, 'Juliana', 3000.00),
(9, 'Fernando', 3400.00),
(10, 'Luiza', 2800.00),
(11, 'Paulo', 3600.00),
(12, 'Camila', 2950.00),
(13, 'Gustavo', 3150.00);
Go
Insert Into Dependente Values 
(5, 4, 'Sofia', 100.00),
(6, 4, 'Lucas', 120.00),
(7, 5, 'Isabela', 80.00),
(8, 6, 'Thiago', 110.00),
(9, 7, 'Laura', 90.00),
(10, 8, 'Mateus', 85.00),
(11, 9, 'Gabriela', 100.00),
(12, 10, 'Daniel', 75.00),
(13, 11, 'Carolina', 95.00),
(14, 12, 'Rodrigo', 105.00);

-- Criando uma function Ex1 a) Código no Github ou Pastebin de uma Function que Retorne uma tabela:
--(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)

Create Function fn_FuncDep()
Returns @tabela Table(
nome_funcionario varchar(150),
nome_dependente varchar(150),
salario_funcinario decimal(7,2),
salario_dependente decimal(7,2)
)
Begin
	Insert into @tabela 
	Select f.nome, d.nome, f.salario, d.salario from Funcionario f, Dependente d 
	where f.codigo = d.codigo_func
	Return
End
GO
Select * from fn_FuncDep()
GO
--b) Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos
--dependentes, mais a do funcionário.
Go
Create Function fn_SomaSalario(@cod int)
Returns decimal(7,2)
as
Begin
	Declare @soma decimal(7,2)
	Set @soma =(Select salario from Funcionario where codigo = @cod)
	
	Declare @dep decimal(7,2)
	set @dep = (Select Sum(d.salario) as salario from Dependente d, Funcionario f 
	where d.codigo_func = f.codigo
	And f.codigo = 4
	group by d.codigo_func
	)
	
	Set @soma = @soma + @dep
	return @soma

End
Go
Select dbo.fn_SomaSalario(4) as Salario_Func_Dep

-- Exercicio 2 a) a partir da tabela Produtos (codigo, nome, valor unitário e qtd estoque), quantos produtos
--estão com estoque abaixo de um valor de entrada

Create table Produtos(
codigo int not null,
nome varchar(150) not null,
valor_unitario decimal(7,2) not null,
qtd_estoque int not null
Primary Key(codigo)
)	
go 
INSERT INTO Produtos VALUES
(1, 'Camiseta', 29.99, 100),
(2, 'Calça Jeans', 59.90, 50),
(3, 'Tênis', 99.99, 30),
(4, 'Boné', 15.50, 80),
(5, 'Moletom', 49.99, 40),
(6, 'Jaqueta', 79.99, 20),
(7, 'Saia', 39.90, 60),
(8, 'Blusa de Frio', 35.99, 25),
(9, 'Shorts', 25.99, 70),
(10, 'Chinelo', 9.99, 90),
(11, 'Vestido', 45.90, 35),
(12, 'Meia', 4.50, 120),
(13, 'Cinto', 12.99, 75),
(14, 'Bermuda', 29.90, 55),
(15, 'Lenço', 8.99, 85);
Go
Create function fn_estoque(@valor int)
returns int
As
Begin 
	Declare @cont int
	Set @cont = (select COUNT(codigo) as qtd from Produtos where qtd_estoque < @valor)
	Return @cont
End
Go
Select dbo.fn_estoque(30) as quantidades_de_produtos_abaixo_do_valor


--Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque
--abaixo de um valor de entrada
Go
Create Function fn_TabelaEstoque(@valor int)
returns @tabela Table (
codigo int,
nome varchar(150),
qtd_estoque int
)
Begin
	Insert into @tabela
	select codigo, nome, qtd_estoque from Produtos where qtd_estoque < @valor
	return
End
Go
Select * from fn_TabelaEstoque(30)

-- Exercicio 3; Criar, uma UDF, que baseada nas tabelas abaixo, retorne
--Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje
Go
Create table Cliente(
codigo int not null,
nome varchar(150) not null
Primary key(codigo)
)
Go 
Create table Produto_1(
codigo int not null,
nome varchar(150) not null,
valor_unitario decimal(7,2) not null,
Primary Key(codigo)
)
go
Create table Cliente_Produto(
nota_fiscal int not null Identity(1,1),
cliente int not null,
produto int not null,
quantidade int not null
Primary key(nota_fiscal)
Foreign key(cliente) references Cliente(codigo),
Foreign key(produto) references Produto_1(codigo),
)
Go

INSERT INTO cliente VALUES
(1, 'Cliente A'),
(2, 'Cliente B'),
(3, 'Cliente C'),
(4, 'Cliente D'),
(5, 'Cliente E');
Go
Insert Into Produto_1 Values
(1, 'Produto X', 29.99),
(2, 'Produto Y', 59.90),
(3, 'Produto Z', 99.99),
(4, 'Produto W', 15.50),
(5, 'Produto V', 49.99);
Go
Insert into Cliente_Produto Values
(1, 1, 10),
(2, 2, 20),
(3, 3, 5),
(4, 4, 15),
(5, 5, 8);
Go

Create Function fn_valorTotal(@nome varchar(150))
Returns decimal(7,2)
As
Begin
Declare @valor decimal(7,2)

set @valor = (Select valor_unitario From Produto_1 where nome = @nome)
Return @valor
End
GO
Create Function fn_ClienteProduto()
returns @tabela Table(
nome_cliente varchar(150),
nome_produto varchar(150),
quantidade int,
valor_total decimal(7,2),
data_hoje date
)
Begin
	Insert into @tabela (nome_cliente, nome_produto, quantidade)
	Select c.nome, p.nome, cl.quantidade from Cliente c, Produto_1 p, Cliente_Produto cl where c.codigo = cl.cliente
	and p.codigo = cl.produto

	Update @tabela
	set valor_total = quantidade * (Select dbo.fn_valorTotal(nome_produto))

	Update @tabela
	set data_hoje = GETDATE()			
	Return
End
Go
select * from fn_ClienteProduto()

