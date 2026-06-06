<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Terraform AWS Web App</title>
    <link rel="stylesheet" href="/styles.css">
  </head>
  <body>
    <main class="shell">
      <section class="hero">
        <p class="eyebrow">AWS final project</p>
        <h1>Terraform Web App</h1>
        <p class="summary">
          This static web application is deployed on an EC2 instance in a public subnet.
          Terraform also provisions the VPC, private RDS MySQL database, S3 asset bucket,
          and security groups.
        </p>
      </section>

      <section class="grid" aria-label="Deployment resources">
        <article class="panel">
          <span class="label">Compute</span>
          <strong>EC2 + Nginx</strong>
          <p>Serves this web app over HTTP from the public subnet.</p>
        </article>
        <article class="panel">
          <span class="label">Database</span>
          <strong>RDS MySQL</strong>
          <p>Private endpoint: <code>${database_endpoint}</code></p>
        </article>
        <article class="panel">
          <span class="label">Assets</span>
          <strong>S3 Bucket</strong>
          <p>Bucket name: <code>${static_assets_bucket}</code></p>
        </article>
      </section>

      <section class="details">
        <h2>Security group rules</h2>
        <ul>
          <li>HTTP port 80 is allowed to the EC2 web server from configured CIDR ranges.</li>
          <li>SSH port 22 is disabled by default unless CIDR ranges are provided.</li>
          <li>MySQL port 3306 is allowed only from the EC2 web server security group.</li>
        </ul>
        <p class="asset">S3 bucket ARN: <code>${static_assets_arn}</code></p>
      </section>
    </main>
    <script src="/app.js"></script>
  </body>
</html>
