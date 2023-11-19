CREATE OR REPLACE FUNCTION get_all_networks()
RETURNS TABLE(network_id INT, name VARCHAR, ssid VARCHAR, password VARCHAR, auto_connect BOOLEAN) AS $$
BEGIN
    RETURN QUERY SELECT * FROM networks;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE upsert_network(_network_id INT, _name VARCHAR, _ssid VARCHAR, _password VARCHAR, _auto_connect BOOLEAN)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM networks WHERE network_id = _network_id) THEN
        UPDATE networks
        SET name = _name, ssid = _ssid, password = _password, auto_connect = _auto_connect
        WHERE network_id = _network_id;
    ELSE
        INSERT INTO networks(name, ssid, password, auto_connect)
        VALUES (_name, _ssid, _password, _auto_connect);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_network(_network_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM assigned_networks WHERE network_id = _network_id;
    DELETE FROM networks WHERE network_id = _network_id;
END;
$$;

