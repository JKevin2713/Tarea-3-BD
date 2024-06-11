using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace proyectoBases2.Pages.Proyecto.EmpresaZ
{
    public class IndexZModel : PageModel
    {

        public List<factura> listaFactura = new List<factura>();
        public string Numero = "";
        public void OnGet()
        {
            
            Numero = Request.Query["Numero"];
            OnPost(Numero);
            
        }

        // Método ejecutado cuando se realiza una solicitud POST
        public void OnPost(string numero)
        {
            if(numero != null)
            {
                if (validarNumero(numero) == true)
                {
                    Console.WriteLine(numero);
                    Numero = numero;
                    numeroBuscar(numero);
                }
            }
            else
            {
                numeroBuscar("");
            }
        }

        // Método para buscar empleados en la base de datos según un criterio de búsqueda
        public void numeroBuscar(string numero)
        {
            // Cadena de conexión a la base de datos
            string connectionString = "Data Source=LAPTOP-K8CP12F2;Initial Catalog=Tarea4;Integrated Security=True;Encrypt=False";

            // Establecer conexión a la base de datos
            using (SqlConnection sqlConnection = new SqlConnection(connectionString))
            {
                sqlConnection.Open();
                using (SqlCommand command = new SqlCommand("consultaFactura", sqlConnection)) // Llamar al procedimiento almacenado
                {
                    command.CommandType = CommandType.StoredProcedure;


                    // Agregar parámetro de entrada
                    command.Parameters.AddWithValue("@InNumeroBuscar", numero);

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
                            factura infoFacturas = new factura();
                            infoFacturas.idFactura = reader.GetInt32(0);
                            infoFacturas.Numero = reader.GetInt64(1);
                            infoFacturas.PagarAntesIVA = reader.GetDecimal(2);
                            infoFacturas.PagarDespuesIVA = reader.GetDecimal(3);
                            infoFacturas.multasNoPagadas = reader.GetDecimal(4);
                            infoFacturas.pagoTotal = reader.GetDecimal(5);
                            infoFacturas.FechaPagoFactura = reader.GetDateTime(6).Date;
                            infoFacturas.FechaDiaGraciaPago = reader.GetDateTime(7).Date;
                            infoFacturas.facturaPagada = reader.GetBoolean(8);

                            // Agregar el objeto empleyee a la lista filtrada
                            listaFactura.Add(infoFacturas);
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

        // Método para validar el formato del criterio de búsqueda por cédula
        public bool validarNumero(string buscar)
        {
            try
            {
                // Verificar que el campo no esté vacío y contenga solo dígitos
                if (buscar.Length != 0 && Regex.IsMatch(buscar, @"^[0-9]+$"))
                {
                    return true;
                }
                return false;
            }
            catch
            {
                return false;
            }
        }
    }
}
