from flask import Flask, render_template, flash, redirect, url_for, request, jsonify
import mysql.connector
import datetime

app = Flask(__name__)
app.secret_key = "#123@##"  # Required for flash messages

# Database connection details
db_config = {
    'host': 'localhost_name',
    'user': 'user_name',
    'password': 'password_of_your_uset',
    'database': 'project_name'
}

# Helper function to establish a database connection
def get_db_connection():
    return mysql.connector.connect(**db_config)

# Routes
@app.route('/')
def home():
    return render_template('index.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/services')
def services():
    return render_template('service.html')

@app.route('/package')
def package():
    return render_template('package.html')

@app.route('/blog_grid')
def blog_grid():
    return render_template('blog.html')

@app.route('/blog_detail')
def blog_detail():
    return render_template('single.html')

@app.route('/destination')
def destination():
    return render_template('destination.html')

@app.route('/travel_guides')
def travel_guides():
    return render_template('guide.html')

@app.route('/testimonial')
def testimonial():
    return render_template('testimonial.html')

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')

        if email and password:
            flash("Login successful!", "success")
            return redirect(url_for('home'))
        else:
            flash("Invalid credentials. Please try again.", "danger")

    return render_template('login.html')

@app.route('/book')
def register():
    return render_template('register.html')

@app.route("/register", methods=["POST"])
def pay():
    name = request.form.get("name")
    email = request.form.get("email")
    phone = request.form.get("phone")
    address = request.form.get("address")
    rental_date = request.form.get("rental_date")
    return_date = request.form.get("return_date")
    houseboat_id = request.form.get("houseboat_id")

    db = get_db_connection()
    cursor = db.cursor()

    try:
        check_query = "SELECT Customer_ID FROM Customer WHERE Email = %s"
        cursor.execute(check_query, (email,))
        customer = cursor.fetchone()

        if customer:
            customer_id = customer[0]
        else:
            insert_customer_query = """
                INSERT INTO Customer (C_Name, Contact_Info, Phone, Email)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(insert_customer_query, (name, address, phone, email))
            db.commit()
            customer_id = cursor.lastrowid

        fetch_amount_query = "SELECT Amount FROM Houseboat WHERE HouseBoat_ID = %s"
        cursor.execute(fetch_amount_query, (houseboat_id,))
        houseboat = cursor.fetchone()

        if not houseboat:
            flash(f"Error: Houseboat with ID {houseboat_id} does not exist.", "danger")
            return redirect(url_for('register'))

        rental_amount = houseboat[0]

        insert_rental_query = """
            INSERT INTO Rental (Customer_ID, HouseBoat_ID, Rental_Date, Return_Date, Amount, Feedback_ID)
            VALUES (%s, %s, %s, %s, %s, NULL)
        """
        cursor.execute(
            insert_rental_query,
            (customer_id, houseboat_id, rental_date, return_date, rental_amount)
        )
        db.commit()

        flash("Rental registered successfully!", "success")
        return redirect(url_for('payment', rental_id=cursor.lastrowid))
    except mysql.connector.Error as err:
        app.logger.error(f"Database error: {err}")
        flash("An error occurred while processing your request.", "danger")
        return redirect(url_for('register'))
    finally:
        cursor.close()
        db.close()

@app.route('/payment', methods=['GET', 'POST'])
def payment():
    rental_id = request.args.get('rental_id')
    if not rental_id:
        return "Rental ID is required.", 400

    db = get_db_connection()
    cursor = db.cursor(dictionary=True)

    try:
        query = """
            SELECT r.Rental_Date, r.Return_Date, r.Amount,
                c.Customer_ID, c.C_Name AS name, c.Email AS email, c.Phone AS phone, c.Contact_Info AS address,
                hb.HouseBoat_ID AS houseboat_id
            FROM Rental r
            JOIN Customer c ON r.Customer_ID = c.Customer_ID
            JOIN Houseboat hb ON r.HouseBoat_ID = hb.HouseBoat_ID
            WHERE r.Rental_ID = %s
        """
        cursor.execute(query, (rental_id,))
        rental_details = cursor.fetchone()
        
        if rental_details:
            # Convert rental_details to a properly formatted dictionary
            formatted_details = {
                'name': rental_details['name'],
                'email': rental_details['email'],
                'phone': rental_details['phone'],
                'address': rental_details['address'],
                'rental_date': rental_details['Rental_Date'].strftime('%Y-%m-%d') if rental_details['Rental_Date'] else None,
                'return_date': rental_details['Return_Date'].strftime('%Y-%m-%d') if rental_details['Return_Date'] else None,
                'houseboat_id': rental_details['houseboat_id'],
                'amount': str(rental_details['Amount'])
            }

            if request.method == 'POST':
                payment_status = request.form.get('payment_status')
                payment_method = request.form.get('payment_method', 'Paypal')  # Default to Paypal if not provided

                if payment_status:
                    # Insert payment record into Payment table
                    insert_payment_query = """
                        INSERT INTO Payment (Customer_ID, Payment_Method, Payment_Status, Rental_ID)
                        VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(insert_payment_query, (rental_details['Customer_ID'], payment_method, payment_status, rental_id))
                    db.commit()

                    flash("Payment processed successfully!" if payment_status == 'Paid' else "Payment pending. You can pay later.", "success")
                    return redirect(url_for('home'))

            return render_template('pay.html', user_details=formatted_details)
        else:
            return "Rental details not found", 404
    except mysql.connector.Error as err:
        return f"Error: {err}"
    finally:
        cursor.close()
        db.close()

@app.route('/feedback', methods=['GET', 'POST'])
def feedback():
    if request.method == 'POST':
        # Retrieve feedback form data
        customer_id = request.form.get('customer_id')
        comments = request.form.get('comments')
        rating = request.form.get('rating')

        try:
            # Use `get_db_connection` to establish a new connection
            db_connection = get_db_connection()
            cursor = db_connection.cursor()

            query = """
            INSERT INTO Feedback (Customer_ID, Comments, Rating)
            VALUES (%s, %s, %s)
            """
            cursor.execute(query, (customer_id, comments, rating))
            db_connection.commit()

            # Flash success message and redirect to services page
            flash("Thank you for your feedback!", "success")
            return redirect(url_for('services'))  # Redirect to services.html

        except mysql.connector.Error as err:
            # Flash error message and redirect to feedback page
            flash(f"Error: {err}", "danger")
            return redirect(url_for('feedback'))

        finally:
            # Ensure cursor and connection are closed after operation
            cursor.close()
            db_connection.close()

    # Fetch all feedback to display on the page
    try:
        # Use `get_db_connection` to establish a new connection
        db_connection = get_db_connection()
        cursor = db_connection.cursor(dictionary=True)

        query = """
        SELECT F.Feedback_ID, C.C_Name AS Customer_Name, F.Comments, F.Rating
        FROM Feedback F
        JOIN Customer C ON F.Customer_ID = C.Customer_ID
        """
        cursor.execute(query)
        feedbacks = cursor.fetchall()

    except mysql.connector.Error as err:
        feedbacks = []
        flash(f"Error fetching feedback: {err}", "danger")

    finally:
        # Ensure cursor and connection are closed after operation
        cursor.close()
        db_connection.close()

    return render_template('feedback.html', feedbacks=feedbacks)


@app.route('/rental_details', methods=['GET', 'POST'])
def rental_details():
    if request.method == 'POST':
        customer_id = request.form['customer_id']
        
        # Connect to database
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Query to get rental details for the customer along with payment status and houseboat name
        cursor.execute('''SELECT rental.rental_id, rental.rental_date, rental.return_date, payment.payment_status, h_name AS houseboat_name
                        FROM rental
                        LEFT JOIN payment ON rental.rental_id = payment.rental_id
                        LEFT JOIN houseboat ON rental.houseboat_id = houseboat.houseboat_id
                        WHERE rental.customer_id = %s''', (customer_id,))
        rentals = cursor.fetchall()
        
        # Query to get customer name
        cursor.execute('''SELECT c_name
                        FROM customer
                        WHERE customer_id = %s''', (customer_id,))
        customer = cursor.fetchone()  # Fetch one result
        
        cursor.close()
        conn.close()
        
        # Pass both the rentals and customer name to the template
        if customer:
            customer_name = customer['c_name']
            return render_template('rentaldetails.html', rentals=rentals, customer_id=customer_id, customer_name=customer_name)
        else:
            return render_template('rentaldetails.html', rentals=None, customer_id=customer_id, customer_name=None)
    
    return render_template('rentaldetails.html', rentals=None, customer_id=None, customer_name=None)

if __name__ == '__main__':
    app.run(debug=True)
