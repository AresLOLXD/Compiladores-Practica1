import 'dart:io';

import 'AnalizadorDeCadenas.dart';

main() async {
  AnalizadorDeCadenas adc = new AnalizadorDeCadenas();
  stdout.writeln("Leyendo archivo");
  await adc.iniciarAutomataFinito();
  stdout.write("Introduce la cadena a probar: ");
  var cadena = stdin.readLineSync();
  adc.comprobarCadena(cadena ?? "");
  for (var error in adc.errores) {
    stdout.writeln(error);
  }
  if (adc.caminos.length == 0) {
    stdout.writeln("La cadena no es aceptada por el automata");
  } else {
    for (var camino in adc.caminos) {
      stdout.writeln("Se encontro el siguiente camino: ${camino.join("=>")}");
    }
  }
}
