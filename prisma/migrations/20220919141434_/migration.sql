-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('admin', 'user', 'manager');

-- CreateEnum
CREATE TYPE "ActivityLevel" AS ENUM ('begginer', 'intermediate', 'advance');

-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "gender" TEXT NOT NULL,
    "age" INTEGER NOT NULL,
    "weigth" DECIMAL(65,30) NOT NULL,
    "heigth" DECIMAL(65,30) NOT NULL,
    "goal" TEXT NOT NULL,
    "level" "ActivityLevel" NOT NULL DEFAULT 'begginer',
    "role" "UserRole" NOT NULL DEFAULT 'user',

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
