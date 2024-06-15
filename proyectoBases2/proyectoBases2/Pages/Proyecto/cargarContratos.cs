using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Reflection;

public class Contratos
{
    public List<Clientes> ListClientes = new List<Clientes>();

    public void conexionC()
    {
        try
        {
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("ConsultaClientesList", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Agregar parámetro de salida
                    SqlParameter outParameter = new SqlParameter("@OutResulTCode", SqlDbType.Int);
                    outParameter.Direction = ParameterDirection.Output;
                    command.Parameters.Add(outParameter);

                    // Ejecutar el comando y procesar los resultados
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            // Crear objeto empleyee y llenarlo con datos del resultado de la consulta
                            Clientes listClientes = new Clientes();
                            listClientes.Id = reader.GetInt32(0);
                            listClientes.Identificacion = reader.GetInt32(1);
                            listClientes.Nombre = reader.GetString(2);
                            listClientes.FechaOperacion = reader.GetDateTime(3);


                            // Agregar el objeto empleyee a la lista filtrada
                            ListClientes.Add(listClientes);
                        }
                    }
                    // Recuperar el valor del parámetro de salida
                    int resultCode = Convert.ToInt32(outParameter.Value);
                    // Manejar el código de resultado según sea necesario
                    Console.WriteLine(resultCode);
                }

                sqlConnection.Close();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }
}
