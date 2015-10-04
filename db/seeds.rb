
cuenta = Cuenta.new(username: 'admin', password: 'adminadmin', administrador: true, tmp_vars: {cuenta_signed_in: false} )
if cuenta.save
  puts "Creada la cuenta de Administrador (admin:adminadmin)."
else
  cuenta.errors.each do |error|
    puts error
    puts cuenta.errors[error]
  end
end

puts "¡Hecho!"