using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace IlacTakipApi.Models;

public partial class AppDbContext : DbContext
{
    public AppDbContext()
    {
    }

    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Glucosemeasurement> Glucosemeasurements { get; set; }

    public virtual DbSet<BloodPressureMeasurement> BloodPressureMeasurements { get; set; }

    public DbSet<Treatment> Treatments { get; set; }

    public virtual DbSet<Emailverificationcode> Emailverificationcodes { get; set; }

    public virtual DbSet<Medication> Medications { get; set; }

    public virtual DbSet<Medicationlog> Medicationlogs { get; set; }

    public virtual DbSet<Medicationschedule> Medicationschedules { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=ilac_takip;Username=postgres;Password=YeniGucluSifre123!");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {

        modelBuilder.Entity<Treatment>(entity =>
{
    entity.HasKey(e => e.Id).HasName("treatments_pkey");

    entity.ToTable("treatments");

    entity.Property(e => e.Id).HasColumnName("id");
    entity.Property(e => e.Userid).HasColumnName("userid");

    entity.Property(e => e.Treatmenttype)
        .HasMaxLength(20)
        .HasColumnName("treatmenttype");

    entity.Property(e => e.Name)
        .HasMaxLength(100)
        .HasColumnName("name");

    entity.Property(e => e.Dose)
        .HasPrecision(6, 2)
        .HasColumnName("dose");

    entity.Property(e => e.Unit)
        .HasMaxLength(20)
        .HasColumnName("unit");

    entity.Property(e => e.Takentime)
        .HasColumnType("timestamp without time zone")
        .HasColumnName("takentime");

    entity.Property(e => e.Note).HasColumnName("note");
});
        modelBuilder.Entity<Glucosemeasurement>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("glucosemeasurements_pkey");

            entity.ToTable("glucosemeasurements");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Measurementtime)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("measurementtime");
            entity.Property(e => e.Measurementtype)
                .HasMaxLength(30)
                .HasColumnName("measurementtype");
            entity.Property(e => e.Note).HasColumnName("note");
            entity.Property(e => e.Userid).HasColumnName("userid");
            entity.Property(e => e.Value)
                .HasPrecision(5, 2)
                .HasColumnName("value");

            entity.HasOne(d => d.User).WithMany(p => p.Glucosemeasurements)
                .HasForeignKey(d => d.Userid)
                .HasConstraintName("fk_glucose_user");
        });

        modelBuilder.Entity<Emailverificationcode>(entity =>
{
    entity.ToTable("emailverificationcodes");

    entity.Property(e => e.Id).HasColumnName("id");
    entity.Property(e => e.Fullname).HasColumnName("fullname");
    entity.Property(e => e.Email).HasColumnName("email");
    entity.Property(e => e.Password).HasColumnName("password");
    entity.Property(e => e.Code).HasColumnName("code");
    entity.Property(e => e.Expiresat).HasColumnName("expiresat");
    entity.Property(e => e.Isused).HasColumnName("isused");
    entity.Property(e => e.Createdat).HasColumnName("createdat");
});

        modelBuilder.Entity<Medication>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("medications_pkey");

            entity.ToTable("medications");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Createdat)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("createdat");
            entity.Property(e => e.Dosage)
                .HasMaxLength(50)
                .HasColumnName("dosage");
            entity.Property(e => e.Name)
                .HasMaxLength(100)
                .HasColumnName("name");
            entity.Property(e => e.Notes).HasColumnName("notes");
            entity.Property(e => e.Type)
                .HasMaxLength(50)
                .HasColumnName("type");
            entity.Property(e => e.Userid).HasColumnName("userid");

            entity.HasOne(d => d.User).WithMany(p => p.Medications)
                .HasForeignKey(d => d.Userid)
                .HasConstraintName("fk_medications_user");
        });

        modelBuilder.Entity<Medicationlog>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("medicationlogs_pkey");

            entity.ToTable("medicationlogs");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Medicationid).HasColumnName("medicationid");
            entity.Property(e => e.Note).HasColumnName("note");
            entity.Property(e => e.Scheduleddatetime)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("scheduleddatetime");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .HasColumnName("status");
            entity.Property(e => e.Takendatetime)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("takendatetime");

            entity.HasOne(d => d.Medication).WithMany(p => p.Medicationlogs)
                .HasForeignKey(d => d.Medicationid)
                .HasConstraintName("fk_log_medication");
        });

        modelBuilder.Entity<Medicationschedule>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("medicationschedules_pkey");

            entity.ToTable("medicationschedules");

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Enddate).HasColumnName("enddate");
            entity.Property(e => e.Frequencytype)
                .HasMaxLength(30)
                .HasColumnName("frequencytype");
            entity.Property(e => e.Hour).HasColumnName("hour");
            entity.Property(e => e.Isactive)
                .HasDefaultValue(true)
                .HasColumnName("isactive");
            entity.Property(e => e.Medicationid).HasColumnName("medicationid");
            entity.Property(e => e.Minute).HasColumnName("minute");
            entity.Property(e => e.Startdate).HasColumnName("startdate");

            entity.HasOne(d => d.Medication).WithMany(p => p.Medicationschedules)
                .HasForeignKey(d => d.Medicationid)
                .HasConstraintName("fk_schedule_medication");
        });

        modelBuilder.Entity<BloodPressureMeasurement>(entity =>
{
    entity.ToTable("bloodpressuremeasurements");

    entity.Property(e => e.Id).HasColumnName("id");

    entity.Property(e => e.Userid)
        .HasColumnName("userid");

    entity.Property(e => e.Systolic)
        .HasColumnName("systolic");

    entity.Property(e => e.Diastolic)
        .HasColumnName("diastolic");

    entity.Property(e => e.Pulse)
        .HasColumnName("pulse");

    entity.Property(e => e.Measurementtime)
        .HasColumnName("measurementtime");

    entity.Property(e => e.Note)
        .HasColumnName("note");
});

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("users_pkey");

            entity.ToTable("users");

            entity.HasIndex(e => e.Email, "users_email_key").IsUnique();

            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Age).HasColumnName("age");
            entity.Property(e => e.ChronicDisease)
                .HasMaxLength(255)
                .HasColumnName("chronicdisease");
            entity.Property(e => e.Createdat)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("createdat");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .HasColumnName("email");
            entity.Property(e => e.Fullname)
                .HasMaxLength(100)
                .HasColumnName("fullname");
            entity.Property(e => e.Gender)
                .HasMaxLength(20)
                .HasColumnName("gender");
            entity.Property(e => e.Height)
                .HasPrecision(5, 2)
                .HasColumnName("height");
            entity.Property(e => e.Password)
                .HasMaxLength(255)
                .HasColumnName("password");
            entity.Property(e => e.Weight)
                .HasPrecision(5, 2)
                .HasColumnName("weight");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
