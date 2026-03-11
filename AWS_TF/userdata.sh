#!/bin/bash
apt update -y
apt install -y apache2

# Get the instance ID using instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install AWS CLI
apt install -y awscli

# Download the Images from S3 bucket
# aws s3 cp s3://ys3bucketapril2026/myimg.png /var/www/html/yimg.png --acl bucket-owner-full-control

# Create simple HTML file or website with the content to display on website
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Natural Foods Producer</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      background: #fdfdfd;
      color: #333;
    }
    header {
      background: #8B4513;
      color: white;
      padding: 1.5rem;
      text-align: center;
    }
    nav {
      background: #333;
      display: flex;
      justify-content: center;
    }
    nav a {
      color: white;
      padding: 1rem;
      text-decoration: none;
    }
    nav a:hover {
      background: #575757;
    }
    main {
      padding: 2rem;
    }
    section {
      margin: 2rem 0;
      text-align: center;
    }
    section img {
      max-width: 300px;
      border-radius: 8px;
      margin-top: 1rem;
    }
    footer {
      background: #333;
      color: white;
      text-align: center;
      padding: 1rem;
      margin-top: 2rem;
    }
  </style>
</head>
<body>
  <header>
    <h1>Welcome to Our Natural Foods</h1>
    <p>Producers of Jaggery Powder, Biscuits & More</p>
  </header>

  <nav>
    <a href="#home">Home</a>
    <a href="#products">Products</a>
    <a href="#about">About Us</a>
    <a href="#contact">Contact</a>
  </nav>

  <main>
    <section id="home">
      <h2>Healthy & Natural</h2>
      <p>We bring you traditional and wholesome food products made with care and quality.</p>
    </section>

    <section id="products">
      <h2>Our Products</h2>
      <div>
        <h3>Jaggery Powder</h3>
        <p>Pure, natural jaggery powder — a healthy alternative to refined sugar.</p>
        <img src="https://mys3bucketapril2026.s3.ap-south-1.amazonaws.com/jaggery.jpg" alt="Jaggery">
      </div>
      <div>
        <h3>Biscuits</h3>
        <p>Crunchy, tasty biscuits made with natural ingredients.</p>
        <img src="https://mys3bucketapril2026.s3.ap-south-1.amazonaws.com/biscuits.jpg" alt="Biscuits">
      </div>
      <div>
        <h3>Snacks & More</h3>
        <p>We also produce traditional sweets, snacks, and more.</p>
        <img src="https://mys3bucketapril2026.s3.ap-south-1.amazonaws.com/snacks.jpg" alt="Snacks">
      </div>
      <div>
        <h3>Snacks & More</h3>
        <p>We also produce traditional sweets, snacks, and more.</p>
        <img src="https://mys3bucketapril2026.s3.ap-south-1.amazonaws.com/powder.jpg" alt="Powder">
      </div>
    </section>

    <section id="about">
      <h2>About Us</h2>
      <p>We are dedicated to producing high-quality, natural food products that combine tradition with taste. Our mission is to promote healthy living through authentic ingredients.</p>
    </section>

    <section id="contact">
      <h2>Contact Us</h2>
      <p>Email: info@naturalfoods.com</p>
      <p>Phone: +91 84110 40425</p>
    </section>
  </main>

  <footer>
    <p>&copy; 2026 Natural Foods Producer</p>
  </footer>
</body>
</html>
EOF

# Start apache and enable it on boot
systemctl start apache2
systemctl enable apache2