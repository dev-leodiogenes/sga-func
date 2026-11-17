// SGA-Func - Exemplo de MongoDB
// Comparacao com o CRUD de disciplinas em PostgreSQL.
// Executar usando: mongosh examples/mongodb-courses.js

const banco = db.getSiblingDB("sga_func_demo");
const disciplinas = banco.getCollection("courses_demo");

// ID exclusivo para preservar outros registros
const id = new ObjectId();

// CREATE
disciplinas.insertOne({
    _id: id,
    code: "MAT-DEMO",
    name: "Matematica",
    workloadHours: 60
});

print("1. Disciplina cadastrada:");
printjson(disciplinas.findOne({ _id: id }));

// READ
print("2. Consulta pelo codigo:");
printjson(disciplinas.findOne({ _id: id, code: "MAT-DEMO" }));

// UPDATE
disciplinas.updateOne(
    { _id: id },
    { $set: { workloadHours: 80 } }
);

print("3. Disciplina atualizada:");
printjson(disciplinas.findOne({ _id: id }));

// DELETE
disciplinas.deleteOne({ _id: id });

print("4. Registro temporario excluido:");
printjson(disciplinas.findOne({ _id: id }));

print("Demonstracao de CRUD concluida.");
