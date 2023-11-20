CREATE OR REPLACE FUNCTION get_all_applications()
RETURNS TABLE(application_id INT, name VARCHAR, apk TEXT) AS $$
BEGIN
    RETURN QUERY SELECT * FROM applications;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE upsert_application(_application_id INT, _name VARCHAR, _apk TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM applications WHERE application_id = _application_id) THEN
        UPDATE applications
        SET name = _name, apk = _apk
        WHERE application_id = _application_id;
    ELSE
        INSERT INTO applications(name, apk)
        VALUES (_name, _apk);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_application(_application_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM assigned_applications WHERE application_id = _application_id;
    DELETE FROM applications WHERE application_id = _application_id;
END;
$$;

