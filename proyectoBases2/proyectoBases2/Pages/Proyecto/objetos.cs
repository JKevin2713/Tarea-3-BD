using Microsoft.AspNetCore.Http.HttpResults;

public class factura
{
    public int idFactura;
    public long Numero;
    public Decimal PagarAntesIVA;
    public Decimal PagarDespuesIVA;
    public Decimal multasNoPagadas;
    public Decimal pagoTotal;
    public DateTime FechaPagoFactura;
    public DateTime FechaDiaGraciaPago;
    public bool facturaPagada;

}
public class DetalleElementoCobro
{
    public int id;
    public int tarifaBasica;
    public int minUsoExceso;
    public Decimal gigasUsoExceso;
    public int minLlamadaFamilia;
    public int cobro911;
    public int cobro110;
    public int cobro900;
    public int cobro800;

}

public class llamada
{
    public int id;
    public long NumeroDe;
    public long NumeroA;
    public string FechaInicio;
    public string FechaFin;
    public DateTime FechaOperacion;
    public int cantMin;

}

public class usoDatos
{
    public int id;
    public long Numero;
    public DateTime fecha;
    public decimal montoMegasConsumidas;
}


public class infoEmplesaXyY
{
    public int id;
    public DateTime FechaCorte;
    public int totalMinLlamadasEntrantes;
    public int totalMinLlamadasSalientes;
    public DateTime FechaApertura;
    public DateTime FechaCierre;
    public string Estado;
}
public class detallesLlamadaXyY
{
    public int id;
    public DateTime FechaCorte;
    public DateTime FechaLlamada;
    public TimeSpan HoraInicio;
    public TimeSpan HoraFin;
    public int Duracion;
    public long NumeroDe;
    public long NumeroA;
    public string TipoLlamada;
}

public class cliente
{
    public DateTime fechaOperacion;
    public int cedulaCliente;
    public string nombreCliente;
    public long numeroCliente;
    public string tipoTarifa;
}

public class tipoTarifa
{

    public int id;
    public string NombreTarifa;
}
