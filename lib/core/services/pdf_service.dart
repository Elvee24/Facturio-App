import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/faturas/domain/entities/fatura.dart';
import '../../features/clientes/domain/entities/cliente.dart';
import 'package:intl/intl.dart';

class PdfService {
  static final formatoMoeda = NumberFormat.currency(
    locale: 'pt_PT',
    symbol: '€',
    decimalDigits: 2,
  );

  static final formatoData = DateFormat('dd/MM/yyyy');

  // Gerar PDF da fatura
  static Future<pw.Document> gerarFaturaPdf(
    Fatura fatura,
    Cliente cliente,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              _buildCabecalho(fatura),
              pw.SizedBox(height: 30),

              // Dados do Cliente
              _buildDadosCliente(cliente),
              pw.SizedBox(height: 30),

              // Tabela de Produtos/Serviços
              _buildTabelaProdutos(fatura),
              pw.SizedBox(height: 20),

              // Totais
              _buildTotais(fatura),
              
              pw.Spacer(),

              // Rodapé
              _buildRodape(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _buildCabecalho(Fatura fatura) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'FATURA',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Text('Nº ${fatura.numero}'),
            pw.Text('Data: ${formatoData.format(fatura.data)}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Sua Empresa Lda.',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text('NIF: 000000000'),
            pw.Text('Morada Empresa'),
            pw.Text('Código Postal - Cidade'),
            pw.Text('Tel: 000 000 000'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDadosCliente(Cliente cliente) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Cliente',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(cliente.nome),
          pw.Text('NIF: ${cliente.nif}'),
          pw.Text(cliente.morada),
          if (cliente.email.isNotEmpty) pw.Text('Email: ${cliente.email}'),
          if (cliente.telefone.isNotEmpty) pw.Text('Tel: ${cliente.telefone}'),
        ],
      ),
    );
  }

  static pw.Widget _buildTabelaProdutos(Fatura fatura) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Cabeçalho
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildCelulaCabecalho('Descrição'),
            _buildCelulaCabecalho('Qtd'),
            _buildCelulaCabecalho('Preço Un.'),
            _buildCelulaCabecalho('IVA %'),
            _buildCelulaCabecalho('Total'),
          ],
        ),
        // Linhas
        ...fatura.linhas.map((linha) {
          return pw.TableRow(
            children: [
              _buildCelula(linha.produtoNome),
              _buildCelula(linha.quantidade.toString(), alinhamento: pw.Alignment.centerRight),
              _buildCelula(formatoMoeda.format(linha.precoUnitario), alinhamento: pw.Alignment.centerRight),
              _buildCelula('${linha.iva}%', alinhamento: pw.Alignment.center),
              _buildCelula(formatoMoeda.format(linha.total), alinhamento: pw.Alignment.centerRight),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildCelulaCabecalho(String texto) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texto,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildCelula(String texto, {pw.Alignment? alinhamento}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Align(
        alignment: alinhamento ?? pw.Alignment.centerLeft,
        child: pw.Text(texto),
      ),
    );
  }

  static pw.Widget _buildTotais(Fatura fatura) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildLinhaTotal('Subtotal:', formatoMoeda.format(fatura.subtotal)),
            _buildLinhaTotal('IVA:', formatoMoeda.format(fatura.totalIva)),
            pw.Divider(),
            _buildLinhaTotal(
              'TOTAL:',
              formatoMoeda.format(fatura.total),
              negrito: true,
              tamanho: 16,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildLinhaTotal(
    String label,
    String valor, {
    bool negrito = false,
    double tamanho = 12,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: tamanho,
            fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: tamanho,
            fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildRodape() {
    return pw.Center(
      child: pw.Text(
        'Obrigado pela sua preferência!',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey,
        ),
      ),
    );
  }

  // Imprimir PDF
  static Future<void> imprimirFatura(Fatura fatura, Cliente cliente) async {
    final pdf = await gerarFaturaPdf(fatura, cliente);
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // Compartilhar PDF
  static Future<void> compartilharFatura(Fatura fatura, Cliente cliente) async {
    final pdf = await gerarFaturaPdf(fatura, cliente);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'fatura_${fatura.numero.replaceAll('/', '_')}.pdf',
    );
  }
}
