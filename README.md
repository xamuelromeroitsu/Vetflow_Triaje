🐾 VetClinic Admin & Triage — Sistema de Gestión y Triaje Clínico

VetClinic Admin & Triage es una solución móvil y web diseñada para optimizar la atención de emergencias, el registro de patologías y la clasificación automatizada de pacientes según la gravedad de sus síntomas en clínicas veterinarias.

📸 Capturas / Previsualización
*(Agrega aquí mockups o capturas de pantalla de la app)*

🚀 Funcionalidades Clave (Épicas del Proyecto)
🚑 1. Captura y Registro de Patologías / Síntomas

* **Ingreso detallado:** Permite registrar los síntomas, signos vitales y antecedentes del paciente de forma estandarizada.
* **Evidencia multimedia:** Soporte para adjuntar fotografías de lesiones o reportes previos para complementar el diagnóstico inicial.
* **Control de constantes vitales:** Validación de campos numéricos (temperatura, peso y frecuencia cardíaca) con rangos lógicos.

⚡ 2. Motor de Clasificación de Riesgo (Triage)

* **Evaluación automatizada:** Categorización inteligente basada en la descripción de patologías y parámetros ingresados.
* **Niveles de prioridad:** Clasificación en tiempo real para priorizar casos críticos (Emergencia vs. Urgencia vs. Consulta).

🏥 3. Gestión de Colas y Derivación de Pacientes

* **Optimización del flujo:** Asignación de salas y médicos correspondientes, mostrando la prioridad en tiempo real en la sala de espera.
* **Derivación eficiente:** Descongestión de las áreas de atención y canalización ordenada de los casos.

📅 4. Gestión de Citas y Consultas Programadas

* **Agendamiento:** Permite programar y dar seguimiento a consultas para casos no urgentes.
* **Optimización operativa:** Descongestiona las salas de espera físicas al derivar casos leves hacia citas controladas.

🗺️ 5. Directorio, Geolocalización y Portal Informativo

* **Geolocalización:** Guía a los usuarios hacia el centro médico más cercano según especialidades y horarios.
* **Portal de salud:** Publicación de artículos, guías de primeros auxilios y alertas comunitarias preventivas.
* **Carnet de salud digital:** Almacenamiento de antecedentes médicos críticos y contactos de emergencia.

🛠️ Arquitectura Técnica y Stack

* **Frontend Móvil:** Flutter (Multiplataforma Android e iOS)
* **Backend as a Service:** Firebase (Cloud Firestore y Storage)
* **Cloud Firestore:** Base de datos NoSQL estructurada por colecciones de pacientes, colas de triaje y registros clínicos.
* **Firebase Authentication:** Gestión de sesiones y roles de usuario (Personal médico, recepción y pacientes).

🗄️ Esquema de Base de Datos (Cloud Firestore)
/clinics/{clinicId}
├── /patients/{patientId}          --> Datos generales y antecedentes de la mascota y propietario
├── /triageQueue/{queueId}         --> Cola activa ordenada por severidad y tiempo de llegada
├── /medicalRecords/{recordId}     --> Consultas, notas, signos vitales y archivos multimedia
└── /appointments/{appId}          --> Gestión de citas programadas y consultas no urgentes
