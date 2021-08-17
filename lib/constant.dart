// API Constant
// ปกติเวลาเรียก ที่ postman จะใช้ ip 127.0.0.1 url ก็จะเป็น http://127.0.0.1:8000 แต่ถ้าเรียกจาก emulator จะเป็น ip http://10.0.2.2:8000
// port 8000 นั้น มาจากเมื่อรันคำสั่ง laravel ==> php artisan serve จะได้ port 8000 เป็นค่า default
const String BASE_API_URL = 'http://10.0.2.2:8000/api'; // Your laravel url.
