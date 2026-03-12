import 'package:flutter/material.dart';
import '../../../../core/i18n/app_text.dart';

class LicencaPage extends StatelessWidget {
  const LicencaPage({super.key});

  static const String _textoPT =
      'Licença MIT (Português – Portugal)\n\n'
      'Copyright (c) 2026 Facturio\n\n'
      'É concedida permissão, gratuitamente, a qualquer pessoa que obtenha uma '
      'cópia deste software e dos ficheiros de documentação associados (o '
      '"Software"), para negociar no Software sem restrições, incluindo, sem '
      'limitação, os direitos de usar, copiar, modificar, fundir, publicar, '
      'distribuir, sublicenciar e/ou vender cópias do Software, e para '
      'permitir que as pessoas a quem o Software é fornecido o façam, sujeito '
      'às seguintes condições:\n\n'
      'O aviso de direitos de autor acima e este aviso de permissão devem ser '
      'incluídos em todas as cópias ou partes substanciais do Software.\n\n'
      'O SOFTWARE É FORNECIDO "TAL COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO, '
      'EXPRESSA OU IMPLÍCITA, INCLUINDO, MAS NÃO SE LIMITANDO ÀS GARANTIAS DE '
      'COMERCIALIZAÇÃO, ADEQUAÇÃO A UMA FINALIDADE ESPECÍFICA E NÃO INFRAÇÃO. '
      'EM NENHUMA CIRCUNSTÂNCIA OS AUTORES OU TITULARES DOS DIREITOS DE AUTOR '
      'SERÃO RESPONSÁVEIS POR QUALQUER RECLAMAÇÃO, DANOS OU OUTRA '
      'RESPONSABILIDADE, SEJA NUMA AÇÃO DE CONTRATO, DELITO OU OUTRA, '
      'DECORRENTE DE, FORA DE OU EM LIGAÇÃO COM O SOFTWARE OU O USO OU OUTRAS '
      'OPERAÇÕES NO SOFTWARE.';

  static const String _textoEN =
      'MIT License\n\n'
      'Copyright (c) 2026 Facturio\n\n'
      'Permission is hereby granted, free of charge, to any person obtaining a '
      'copy of this software and associated documentation files (the '
      '"Software"), to deal in the Software without restriction, including '
      'without limitation the rights to use, copy, modify, merge, publish, '
      'distribute, sublicense, and/or sell copies of the Software, and to '
      'permit persons to whom the Software is furnished to do so, subject to '
      'the following conditions:\n\n'
      'The above copyright notice and this permission notice shall be included '
      'in all copies or substantial portions of the Software.\n\n'
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS '
      'OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF '
      'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. '
      'IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY '
      'CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, '
      'TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE '
      'SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.';

  @override
  Widget build(BuildContext context) {
    final isEn = AppText.isEnglish(context);
    final titulo = isEn ? 'Licence' : 'Licença';
    final texto = isEn ? _textoEN : _textoPT;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Text(
                texto,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
