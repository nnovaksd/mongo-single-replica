try {
  var username = "root";
  db.getSiblingDB('admin').createUser({
    user: username,
    pwd: "root123",
    roles: [
      { role: "root", db: "admin" },
    ]
  });
  print("[DEBUG] User "+username+" created successfully in admin database.");
} catch (e) {
  print("[DEBUG] Error creating user"+username+": " + e);
}