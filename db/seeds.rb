# Non-destructive, repeatable sample data.
# Existing records, prices, assignments, and passwords are preserved.
# Natural keys: service name, staff name, customer phone, bike serial number.
# Sample repairs are identified by their original bike/mechanic pair.

# -------------------------------------------------------------------
# Services
# -------------------------------------------------------------------

service_data = [
  ["Tune-up", 45000],
  ["Wheel true", 18000],
  ["Brake bleed", 25000],
  ["Chain replacement", 15000],
  ["Flat tire repair", 12000],
  ["Brake adjustment", 12000],
  ["Gear adjustment", 15000],
  ["Bottom bracket service", 22000],
  ["Headset adjustment", 12000],
  ["Hub service", 20000],
  ["Cable replacement", 10000],
  ["Tubeless setup", 20000],
  ["Cassette replacement", 18000],
  ["Brake pad replacement", 14000],
  ["Tire replacement", 12000],
  ["Fork service", 35000],
  ["Drivetrain cleaning", 20000],
  ["Pedal installation", 8000],
  ["Wheel replacement", 15000],
  ["Safety inspection", 10000]
]

services = {}

service_data.each do |name, price|
  services[name] = Service.find_or_create_by!(name: name) do |service|
    service.current_price = price
  end
end

# -------------------------------------------------------------------
# Staff
# -------------------------------------------------------------------

staff = {}

[
  ["Daniel Soto", "Mechanic"],
  ["Camila Reyes", "Mechanic"],
  ["Tomás Silva", "Mechanic"],
  ["Sofía Morales", "Counter Worker"]
].each do |name, role|
  staff[name] = Staff.find_or_create_by!(name: name) do |member|
    member.role = role
  end
end

# -------------------------------------------------------------------
# Customers
# -------------------------------------------------------------------

customers = {}

[
  ["Ana Torres", "+56 9 1111 1111"],
  ["Benjamín Pérez", "+56 9 2222 2222"],
  ["Carolina Díaz", "+56 9 3333 3333"],
  ["Diego Muñoz", "+56 9 4444 4444"],
  ["Elena Vargas", "+56 9 5555 5555"],
  ["Felipe Rojas", "+56 9 6666 6666"],
  ["Gabriela Soto", "+56 9 7777 7777"],
  ["Hugo Fernández", "+56 9 8888 8888"],
  ["Isidora López", "+56 9 9999 9999"],
  ["Joaquín Castro", "+56 9 1010 1010"]
].each do |name, phone|
  customers[name] = Customer.find_or_create_by!(phone: phone) do |customer|
    customer.name = name
  end
end

# -------------------------------------------------------------------
# Bikes
# -------------------------------------------------------------------

bikes = {}

bike_data = [
  ["bike_1", "Ana Torres",      "Trek",        "Marlin 5",    "Blue",   "WH-001"],
  ["bike_2", "Benjamín Pérez",  "Trek",        "Marlin 5",    "Blue",   "WH-002"],
  ["bike_3", "Carolina Díaz",   "Specialized", "Rockhopper",  "Red",    "WH-003"],
  ["bike_4", "Diego Muñoz",     "Giant",       "Talon 3",     "Black",  "WH-004"],
  ["bike_5", "Elena Vargas",    "Cannondale",  "Trail 5",     "Green",  "WH-005"],
  ["bike_6", "Felipe Rojas",    "Scott",       "Aspect 950",  "Gray",   "WH-006"],
  ["bike_7", "Gabriela Soto",   "Trek",        "Domane AL 2", "White",  "WH-007"],
  ["bike_8", "Hugo Fernández",  "Giant",       "Contend 3",   "Blue",   "WH-008"],
  ["bike_9", "Isidora López",   "Merida",      "Big Nine",    "Black",  "WH-009"],
  ["bike_10", "Ana Torres",     "Oxford",      "Orion",       "Silver", "WH-010"],
  ["bike_11", "Diego Muñoz",    "Scott",       "Scale 980",   "Orange", "WH-011"],
  ["bike_12", "Felipe Rojas",   "Trek",        "FX 2",        "Gray",   "WH-012"]
]

bike_data.each do |key, customer_name, make, model, color, serial|
  bikes[key] = Bike.find_or_create_by!(serial_number: serial) do |bike|
    bike.customer = customers.fetch(customer_name)
    bike.make = make
    bike.model = model
    bike.color = color
  end
end

# -------------------------------------------------------------------
# Repairs
# -------------------------------------------------------------------

repairs = {}

def create_repair(bikes, staff, key, bike_key, mechanic_name, status,
                  received_days_ago, promised_offset,
                  quoted_price: nil, decision: nil, handed_back_at: nil)

  bike = bikes.fetch(bike_key)
  mechanic = mechanic_name ? staff.fetch(mechanic_name) : nil

  Repair.find_or_create_by!(bike: bike, mechanic: mechanic) do |repair|
    repair.status = status
    repair.received_at = Time.current - received_days_ago.days
    repair.promised_on = Date.current + promised_offset.days
    repair.handed_back_at = handed_back_at
    repair.quoted_price = quoted_price
    repair.customer_decision = decision
    repair.intake_condition = "Bike received with normal signs of use."
  end
end

repairs["received"] = create_repair(
  bikes, staff, "received",
  "bike_1", nil,
  "received",
  0, 3
)

repairs["diagnosing"] = create_repair(
  bikes, staff, "diagnosing",
  "bike_2", "Daniel Soto",
  "diagnosing",
  1, 2
)

repairs["awaiting"] = create_repair(
  bikes, staff, "awaiting",
  "bike_3", "Camila Reyes",
  "awaiting_approval",
  2, 2,
  quoted_price: 45000
)

repairs["repairing"] = create_repair(
  bikes, staff, "repairing",
  "bike_4", "Tomás Silva",
  "in_repair",
  3, 1,
  quoted_price: 60000,
  decision: "approved"
)

repairs["ready"] = create_repair(
  bikes, staff, "ready",
  "bike_5", "Daniel Soto",
  "ready_for_pickup",
  4, 0,
  quoted_price: 37000,
  decision: "approved"
)

repairs["completed"] = create_repair(
  bikes, staff, "completed",
  "bike_6", "Camila Reyes",
  "completed",
  8, -4,
  quoted_price: 45000,
  decision: "approved",
  handed_back_at: Time.current - 4.days
)

# Overdue and not handed back.
repairs["overdue"] = create_repair(
  bikes, staff, "overdue",
  "bike_7", "Tomás Silva",
  "in_repair",
  7, -2,
  quoted_price: 70000,
  decision: "approved"
)

# Customer rejected quote -> ready for pickup.
repairs["rejected"] = create_repair(
  bikes, staff, "rejected",
  "bike_8", "Daniel Soto",
  "ready_for_pickup",
  5, 0,
  quoted_price: 90000,
  decision: "rejected"
)

# Same-day repair.
same_day_received = Time.current - 12.days

repairs["same_day"] = Repair.find_or_create_by!(
  bike: bikes.fetch("bike_9"), mechanic: staff.fetch("Camila Reyes")
) do |repair|
  repair.status = "completed"
  repair.received_at = same_day_received
  repair.promised_on = same_day_received.to_date
  repair.handed_back_at = same_day_received + 5.hours
  repair.quoted_price = 25000
  repair.customer_decision = "approved"
  repair.intake_condition = "Bike received in good general condition."
end

# More repairs so that one bike has repair history.
repairs["history_1"] = create_repair(
  bikes, staff, "history_1",
  "bike_1", "Daniel Soto",
  "completed",
  30, -27,
  quoted_price: 30000,
  decision: "approved",
  handed_back_at: Time.current - 27.days
)

repairs["history_2"] = create_repair(
  bikes, staff, "history_2",
  "bike_1", "Tomás Silva",
  "completed",
  15, -12,
  quoted_price: 40000,
  decision: "approved",
  handed_back_at: Time.current - 12.days
)

repairs["extra_1"] = create_repair(
  bikes, staff, "extra_1",
  "bike_10", "Daniel Soto",
  "diagnosing",
  1, 4
)

repairs["extra_2"] = create_repair(
  bikes, staff, "extra_2",
  "bike_11", "Camila Reyes",
  "in_repair",
  4, 1,
  quoted_price: 50000,
  decision: "approved"
)

repairs["extra_3"] = create_repair(
  bikes, staff, "extra_3",
  "bike_12", "Tomás Silva",
  "awaiting_approval",
  2, 3,
  quoted_price: 55000
)

# Repair before January of the current year.
old_received = Date.current.beginning_of_year - 2.months

repairs["old"] = Repair.find_or_create_by!(
  bike: bikes.fetch("bike_4"), mechanic: staff.fetch("Daniel Soto")
) do |repair|
  repair.status = "completed"
  repair.received_at = old_received.to_time
  repair.promised_on = old_received + 3.days
  repair.handed_back_at = (old_received + 3.days).to_time
  repair.quoted_price = 50000
  repair.customer_decision = "approved"
  repair.intake_condition = "Bike received with worn drivetrain."
end

# -------------------------------------------------------------------
# Repair services
# -------------------------------------------------------------------

def add_service(repair, service, charged_price = nil)
  RepairService.find_or_create_by!(repair: repair, service: service) do |item|
    item.charged_price = charged_price || service.current_price
  end
end

add_service(repairs["received"], services["Safety inspection"])

add_service(repairs["diagnosing"], services["Gear adjustment"])
add_service(repairs["diagnosing"], services["Safety inspection"])

add_service(repairs["awaiting"], services["Tune-up"])

add_service(repairs["repairing"], services["Brake bleed"])
add_service(repairs["repairing"], services["Brake adjustment"])

add_service(repairs["ready"], services["Chain replacement"])
add_service(repairs["ready"], services["Gear adjustment"])

add_service(repairs["completed"], services["Tune-up"])

add_service(repairs["overdue"], services["Fork service"])
add_service(repairs["overdue"], services["Brake bleed"])

add_service(repairs["rejected"], services["Wheel replacement"])

add_service(repairs["same_day"], services["Brake bleed"])

add_service(repairs["history_1"], services["Flat tire repair"])
add_service(repairs["history_1"], services["Brake adjustment"])

add_service(repairs["history_2"], services["Drivetrain cleaning"])
add_service(repairs["history_2"], services["Gear adjustment"])

add_service(repairs["extra_1"], services["Hub service"])

# Discounted service.
add_service(
  repairs["extra_2"],
  services["Tune-up"],
  services["Tune-up"].current_price - 5000
)

add_service(repairs["extra_3"], services["Bottom bracket service"])
add_service(repairs["extra_3"], services["Headset adjustment"])

# Historical prices intentionally differ from today's prices.
add_service(repairs["old"], services["Tune-up"], 30000)
add_service(repairs["old"], services["Brake adjustment"], 10000)

puts "Seed complete:"
puts "#{Service.count} services"
puts "#{Staff.count} staff members"
puts "#{Customer.count} customers"
puts "#{Bike.count} bikes"
puts "#{Repair.count} repairs"
puts "#{RepairService.count} repair services"


# Lab 9: multimedia seeds

multimedia_repairs = repairs.values.first(10)
raise "At least 10 sample repairs are required" if multimedia_repairs.size < 10

multimedia_repairs.each_with_index do |repair, index|
  unless repair.diagnosis.present?
    repair.update!(
      diagnosis: <<~HTML
        <p><strong>Inspection #{index + 1}</strong></p>
        <p>Initial inspection of the bicycle.</p>
        <ul>
          <li>Check brakes and tires</li>
          <li>Inspect chain and transmission</li>
          <li>Verify safety before delivery</li>
        </ul>
      HTML
    )
  end

  photo_numbers = index.zero? ? [1, 2, 3, 4] : [((index + 3) % 12) + 1]

  existing_names = repair.intake_photos.map do |photo|
    photo.blob.filename.to_s
  end

  photo_numbers.each do |number|
    filename = format("bike_%02d.png", number)
    next if existing_names.include?(filename)

    path = Rails.root.join("db", "seeds", "images", filename)

    File.open(path, "rb") do |file|
      repair.intake_photos.attach(
        io: file,
        filename: filename,
        content_type: "image/png"
      )
    end
  end
end

puts "Lab 9 multimedia seeds completed."

seed_accounts = [
  {
    email: "owner@wheelhouse.test",
    role: :owner,
    staff: nil
  },
  {
    email: "counter@wheelhouse.test",
    role: :counter,
    staff: nil
  },
  {
    email: "daniel@wheelhouse.test",
    role: :mechanic,
    staff: staff.fetch("Daniel Soto")
  },
  {
    email: "camila@wheelhouse.test",
    role: :mechanic,
    staff: staff.fetch("Camila Reyes")
  }
]

seed_accounts.each do |data|
  user = User.find_or_initialize_by(email_address: data[:email])

  if user.new_record?
    user.password = "Wheelhouse2026!"
    user.password_confirmation = "Wheelhouse2026!"
  end

  user.role = data[:role]
  user.staff = data[:staff]
  user.save!

  puts "#{user.email_address}: #{user.role}"
end