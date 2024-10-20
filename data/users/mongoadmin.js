try {
  var username = "mongoadmin";
  db.getSiblingDB('admin').createUser({
    user: username,
    pwd: "secret123",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  });
  print("[DEBUG] User "+username+" created successfully in admin database.");
} catch (e) {
  print("[DEBUG] Error creating user"+username+": " + e);
}
