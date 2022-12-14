import 'dart:io';

import 'AnalizadorDeCadenas.dart';

/**
 * Es la funcion principal del programa, es el main donde inicia la ejecucion
 * y que ademas es una funcion asincrona para poder llamar a iniciarAutomataFinito
 */
main() async {
  AnalizadorDeCadenas adc =
      new AnalizadorDeCadenas(); //Creamos una instancia del analizador de cadenas

  stdout.writeln("Leyendo archivo"); //Mensaje para avisar
  bool fueExistoso = await adc
      .iniciarAutomataFinito(); //Espera a que termine de iniciar el automata (Leer el archivo)
  if (fueExistoso) {
    //Verifica que no hubo errores
    stdout.writeln("Termino la lectura del archivo"); //Mensaje para avisar
    stdout.write(
        "Introduce la cadena a probar: "); //Mensaje que solicita la cadena para el analisis
    var cadena = stdin.readLineSync(); //Se recibe la cadena
    adc.comprobarCadena(cadena ??
        ""); //Se manda a llamar la funcion de comprobarCadena sabiendo que la cadena puede ser null, por eso el ?? ""

    if (adc.caminos.length == 0) {
      //Si no hay caminos, significa que no llego a un estado de aceptacion
      stdout.writeln("La cadena no es aceptada por el automata");
    } else {
      for (var i = 0; i < adc.caminos.length; i++) {
        var camino = adc.caminos[i];
        var errores = adc.errores[i];
        //Se imprimen los caminos en el formato n=>m=>...=>k
        stdout.writeln(
            "Se encontro el siguiente camino: ${"q" + camino.join("=>q")}");
        for (var error in errores) {
          stdout.writeln(error);
        }
        stdout.writeln("\n");
      }
    }
  } else {
    stdout.writeln(
        "Hubo un problema al intentar iniciar el automata"); //Mensaje para avisar
  }
}
