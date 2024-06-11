using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;


namespace proyectoBases2.Pages.Proyecto.EmpresaZ
{
    public class DetallesCobroModel : PageModel
    {

        public List<DetalleElementoCobro> listaDetalleFactura = new List<DetalleElementoCobro>();
        public string idFactura = "";
        public string Numero = "";
        public string FechaFactura = "";
        public void OnGet()
        {
            idFactura = Request.Query["idFactura"];
            Numero = Request.Query["Numero"];
            FechaFactura = Request.Query["FechaFactura"];
            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("consultaDetalleFactura", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;


                    // Agregar parámetro de entrada
                    command.Parameters.AddWithValue("@InIdFactura", idFactura);

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
                            DetalleElementoCobro detalle = new DetalleElementoCobro();
                            detalle.id = reader.GetInt32(0);
                            detalle.tarifaBasica = reader.GetInt32(1);
                            detalle.minUsoExceso = reader.GetInt32(2);
                            detalle.gigasUsoExceso = reader.GetDecimal(3);
                            detalle.minLlamadaFamilia = reader.GetInt32(4);
                            detalle.cobro911 = reader.GetInt32(5);
                            detalle.cobro110 = reader.GetInt32(6);
                            detalle.cobro900 = reader.GetInt32(7);
                            detalle.cobro800 = reader.GetInt32(8);

                            // Agregar el objeto empleyee a la lista filtrada
                            listaDetalleFactura.Add(detalle);
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
    }
}
