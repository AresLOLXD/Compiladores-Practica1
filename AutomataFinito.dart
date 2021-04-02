import 'dart:collection'; //Es necesaria esta biblioteca para los LinkedHashMap

class AutomataFinito {
  /**
   * Los elementos son final y deben empezar con guion bajo.
   * El guion bajo es para que sea privado, y el final es para que no se
   * pueda cambiar los elementos pero que si se puedan modificar sus elementos
   */
  final List<String> _alfabeto;
  final List<int> _estados;
  final List<int> _estadosFinales;
  final int _estadoInicial;
  /**
   * Utilice un HashMap ya que es la forma mas facil de mantener una especie 
   * de tabla con transiciones, es de manera parecida a como se representa un grafo
   * con listas de transiciones, solo que en este caso es necesario un estado y un 
   * caracter para poder obtener una lista, utilice dos HashMap.
   * El primero funciona para el estado, el segundo funciona para el caracter y ya por
   * ultimo guarda una lista con los estados destino.
   * El por que un LinkedHashMap es por simplicidad, crea un arbol autobalanceado, entonces
   * al momento de iterarlo se hace de menor a mayor.
   */
  final LinkedHashMap<int, LinkedHashMap<String, List<int>>>
      _funcionDeTransicion;

  /**
   * Getters de los elementos del automatas.
   * No son necesarios los setters ya que no se modifica el automata
   */
  get alfabeto => _alfabeto;
  get estados => _estados;
  get estadosFinales => _estadosFinales;
  get estadoInicial => _estadoInicial;

  /**
   * Constructor del automata
   */
  AutomataFinito(var alfabeto, var estados, estadosFinales, var estadoInicial,
      var funcionDeTransicion)
      : _alfabeto = alfabeto,
        _estados = estados,
        _estadosFinales = estadosFinales,
        _estadoInicial = estadoInicial,
        _funcionDeTransicion = funcionDeTransicion;

  /**
   * Constructor para un automata vacio
   */
  AutomataFinito.empty()
      : _alfabeto = [],
        _estados = [],
        _estadosFinales = [],
        _estadoInicial = -1,
        _funcionDeTransicion = new LinkedHashMap();

  /**
   * Es la funcion de transicion donde se buscan los [estadosDestinos] con base al 
   * [estado] y al [caracter].
   * 
   * Regresa la lista de los estados destino, si no hay caminos(lo cual es imposible)
   * regresa una lista vacia y en caso de que el caracter no este incluido en el alfabeto
   * regresa un null
   */
  obtenerTransicion(int estado, String caracter) {
    if (_alfabeto.contains(caracter)) {
      if ((_funcionDeTransicion[estado])?.containsKey(caracter) ?? false) {
        return (_funcionDeTransicion[estado])?[caracter];
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  /**
   * La funcion completarAutomataFinito, como su nombre lo dice, revisa
   * que el automata tenga transiciones con todos sus caracteres y, 
   * en caso de que sea necesario, crea las transiciones e incluso el estado faltante
   * para que sea un AutomataCompleto.
   */
  completarAutomataFinito() {
    var bandera = false; //Bandera para romper el ciclo
    var copiaEstados = List.of(
        _estados); //Creo una copia de los estados, ya que voy a iterar sobre ellos y no puedo modificar la lista mientras la itero
    if (!_estados.contains(-1)) {
      //Uso el estado -1 como el estado "muerto" o de negacion
      //Ademas este if es solamente para saber si debe acompletarse el automata
      for (var estado in copiaEstados) {
        //Itero sobre todos los estados para verificar sus transiciones
        for (var caracter in _alfabeto) {
          //Lo mismo de arriba excepto que para los caracteres
          if (!_funcionDeTransicion.containsKey(
                  estado) || //La primera validacion es para saber que por cada estado de origen existe la transicion
              !((_funcionDeTransicion[estado])?.containsKey(caracter) ??
                  true)) {
            //La segunda validacion es para que por cada caracter exista la transicion
            _estados
                .add(-1); //Agrego el estado "muerto" a los estados existentes
            _funcionDeTransicion[-1] = new LinkedHashMap<String, List<int>>();
            //Creo espacio para transicion pero aun no se agrega
            bandera = true;
            break; //Se rompe el ciclo por que ya no es necesario seguir buscando
          }
        }
        if (bandera) break;
      }
    }
    //En este for ya no necesito verificar si alguna transicion no existe, ya que ya lo hizo el for de arriba
    for (var estado in _estados) {
      for (var caracter in _alfabeto) {
        if (!_funcionDeTransicion.containsKey(estado)) {
          //Si no existen transiciones para el estado, se crea su espacio para transiciones
          _funcionDeTransicion[estado] = new LinkedHashMap<String, List<int>>();
        }
        if (!((_funcionDeTransicion[estado])?.containsKey(caracter) ?? true)) {
          //Si no existe transicion del estado con el caracter se manda automaticamente al estado "muerto"
          (_funcionDeTransicion[estado])?[caracter] = [-1];
        }
      }
      if (!_funcionDeTransicion.containsKey(estado)) {
        //Si no existen transiciones para el estado, se crea su espacio para transiciones
        _funcionDeTransicion[estado] = new LinkedHashMap<String, List<int>>();
      }
      if (!((_funcionDeTransicion[estado])?.containsKey("") ?? true)) {
        //Si no existe transicion del estado con el caracter se manda automaticamente al estado "muerto"
        (_funcionDeTransicion[estado])?[""] = [-1];
      }
    }
  }

  /**
   * La funcion toString() sobrecargada,
   * Imprime el mismo formato que como se lee en el archivo AF.txt
   */
  @override
  toString() {
    String output = "";
    output += "${_estados.join(",")}\n";
    output += "${_alfabeto.join(",")}\n";
    output += "${_estadoInicial}\n";
    output += "${_estadosFinales.join(",")}\n";

    _funcionDeTransicion.forEach((estado, transicion) {
      transicion.forEach((caracter, estados) {
        for (var estadoF in estados) {
          if (caracter != "" || estadoF != -1) {
            output += "$estado,"
                "${caracter == "" ? "e" : caracter},"
                "$estadoF\n";
          }
        }
      });
    });

    return output;
  }
}
