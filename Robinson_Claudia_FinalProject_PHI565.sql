SELECT TOP (1000) [State]
      ,[HospitalDepartment]
      ,[Department]
      ,[PatientDailyAdmission]
      ,[InternalCost]
      ,[PatientCost]
      ,[FreeServiceCount]
  FROM [CLASSTABLES].[dbo].[FinalProject]


  select *
  from finalproject
  GO


  DROP Procedure if exists patient_cost_increase

  GO

  CREATE Procedure patient_cost_increase
AS
BEGIN
	update fp
	set PatientCost = PatientCost + 10
	from finalproject fp
	where State = 'Mississippi'
END;

GO



EXEC patient_cost_increase

GO


 select *
 from finalproject

 GO
