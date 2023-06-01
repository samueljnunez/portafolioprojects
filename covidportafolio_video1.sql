----revision2, union de ambas tablas
select*
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date

--buscar la poblacion total vs vacunados
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3
---por dia...
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cadena_personas_vacunadas
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
--forma para remplazar cast, convert(float, variable)
/*el argumento coloca la suma total de nuevas vacunas y la agrega a la columna final, pero
la columna new_v, queda desorganizada, agregando la siguiente funcion al partition by, ordena 
y va haciendo la suma automatica de los valores..(partition by variable order by variable que
desees ordernar, siguiente variable en caso de ser varias))*/

----personas siendo vacunadas vs poblacion temptable y cte
--use cte: paso a paso
--1. with nombre del cte, (todas las columnas que se encuentran en la sintaxis anterior) 
--2. as (todo el argumento, sintaxis o extracto de tabla anterior)

with popvsvac (continent, location, date, population, new_vaccinations, cadena_personas_vacunadas)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cadena_personas_vacunadas
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
select*,  (cadena_personas_vacunadas/population)*100 ---el resultado es el porcentaje de la poblacion vacunada..
from popvsvac           ----ejecutar junto con la cte(el with inicial)

---las columnas en el CTE deben ser la mismas del select, de la tabla creada que sera revisada,
---de lo contrario marcara un error, ovbiar el (order by) ya que el cte las organizara.
/*se puede realizar cualquier medida, solo tener cuidado con las columnas del join, la 
columna date, la eliminas y mides los demas valores..*/

--temp table:
--1.crear tabla #temporal, asignar columnas y tipos de valores
--2. insert into #temporal, insertar todo el argumento anteriormente trabajado
--3. select*, el calculo que desees realizar con el argumento anterior, from #temporal

drop table if exists #porcientopoblacionvacunada --para poder volver a mostrar las tablas temporales, se borran y se ejecutan con este mandato
create table #porcientopoblacionvacunada
(
continente nvarchar(255),
localidad nvarchar(255),
fecha datetime,
poblacion numeric,
nuevos_vacunados numeric,
cadena_personas_vacunadas numeric)

insert into #porcientopoblacionvacunada
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cadena_personas_vacunadas
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
---order by 2,3

select*,  (cadena_personas_vacunadas/poblacion)*100 
from #porcientopoblacionvacunada         

-----crear vistas para salvar datos para luego integrar a tableau or bi.---
--1. create view nombre_asignado as
--2. insertar los argumentos o sintaxis creada.
--3. ejecutar, revisar si se guardo en views de nuestro portafolio

create view porcientopoblacionvacunada as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as cadena_personas_vacunadas
from portafolioproject.dbo.coviddeaths dea
join portafolioproject.dbo.covidvacunacion vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3